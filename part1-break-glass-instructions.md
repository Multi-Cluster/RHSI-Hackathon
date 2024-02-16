# Red Hat Service Interconnect - February APAC Hackathon

# Scenario 1 - Service Sync ENABLED

## Step 1: Inventory of "Monoliths" Existing Pods
Begin by reviewing the deployment that was provided for you.

Replace ``<your-team>`` with the team name provided by your facilitator.  
Using the  project ```<yourteam>-full-s1``` on the ```on-prem``` cluster, get all the pods.

```
oc login -u <your-team> <cluster url>

oc project <yourteam>-full-s1

oc get pods

```

The following pods are currently set up:

```
NAME                                     READY   STATUS    RESTARTS   AGE
adservice-76bdd69666-ckc5j               1/1     Running   0          2m58s
cartservice-66d497c6b7-dp5jr             1/1     Running   0          2m59s
checkoutservice-666c784bd6-4jd22         1/1     Running   0          3m1s
currencyservice-5d5d496984-4jmd7         1/1     Running   0          2m59s
emailservice-667457d9d6-75jcq            1/1     Running   0          3m2s
frontend-6b8d69b9fb-wjqdg                1/1     Running   0          3m1s
loadgenerator-665b5cd444-gwqdq           1/1     Running   0          3m
paymentservice-68596d6dd6-bf6bv          1/1     Running   0          3m
productcatalogservice-557d474574-888kr   1/1     Running   0          3m
recommendationservice-69c56b74d4-7z8r5   1/1     Running   0          3m1s
redis-cart-5f59546cdd-5jnqf              1/1     Running   0          2m58s
shippingservice-6ccc89f8fd-v686r         1/1     Running   0          2m58s
```

Get the route so you can access the application via the route. Note that it is HTTP, not HTTPS in the url.  
```
oc get routes
```
E.g. http://frontend-team1-full-s1.apps.cluster-2txjp.2txjp.sandbox2634.opentlc.com  

## Step 2: Access the Three Target OpenShift Clusters

***In separate terminal windows***, login to the ```AWS MELB``` and ```AWS SYD``` and ```AWS SING``` OpenShift (OCP) clusters. E.g.:  

   ![Front screen](./docs/img/s1-login.png)  


The application will be deployed into three tiers distributed across the three clusters. The project/cluster mapping is:  
  | Project | Cluster | Notes |
  |---------|---------|-------|
  | < your-team >-base-s1 | ON-PREM | Full single-namespace application |
  | < your-team >-tier1-s1 | AWS MELB | Front end services |
  | < your-team >-tier2-s1 | AWS SYD | Cart, Product Catalog, Currency, Shipping, Checkout, Recommendation, Ad, and Redis cache |
  | < your-team >-tier3-s1 | AWS SING | Payment and Email services. |  


## Step 3: Create the namespaces

Because we will be progressively migrating and avoiding application outages, we must first deploy Service Interconnect into each project.  

Using the naming convention in the table above, create the namespaces in each cluster. E.g. on the ``AWS MELB`` cluster you would enter this command:  

```
oc new-project <your-team>-tier1-s1
```


## Step 4: Skupper Initialisation
Once you have created each project, install Service Interconnect.

#### On Premises (Full Application)
```
skupper init --site-name on-prem --enable-console --enable-flow-collector --console-auth=internal --console-user=admin --console-password=password
```

#### AWS-MELB (Tier 1)
```
skupper init --site-name tier-1 --enable-console --enable-flow-collector --console-auth=internal --console-user=admin --console-password=password
```


#### AWS-SYD (Tier 2)
```
skupper init --site-name tier-2 --enable-console --enable-flow-collector --console-auth=internal --console-user=admin --console-password=password
```


#### AWS-SING (Tier 3)
```
skupper init --site-name tier-3 --enable-console --enable-flow-collector --console-auth=internal --console-user=admin --console-password=password
```

**Note:** From this point forward we will refer to each project as ```Base```, ```Tier 1```, ```Tier 2```, or ```Tier 3```.

You have now installed Service Interconnect. You can access the Service Interconnect console through the route. E.g. In the ```Base``` project, 
```
oc get route skupper
```

Paste the route from above into your browser.  The username/password is: ``admin/password``. Keep this tab open and use it to observe what is happening in the network as you proceed through the steps.

   <img src=./docs/img/s1-console.png alt="Console" width="700" height="400">


## Step 5: Create the Service Interconnect Network

Next create the links between the sites. The links will be established in the direction of "most trusted site" to "less trusted site." I.e. **Base --> Tier 3 --> Tier 2 --> Tier 1**

Note, because we are migrating tiers one at a time we would most likely establish the link according to this table (where Site A is higher trust than Site B):

| Site A | Site B |
| -------|--------|
| Base | Tier 1, Tier 2, Tier 3 |
| Tier 3 | Tier 2 |
| Tier 2 | Tier 1 |

This would stop the network flows bewteen Tier 2/Tier 3 and Tier 1/Tier 2 always having to flow through Base. We won't do that because the instructions become more complex. However, you can do this yourself if you like.

This direction is important because endorsed network paths typically flow form high trust to low trust and not the other way around.

### Commands:

#### Tier 1
1. Generate a token.

```
skupper token create ~/tier1.token
cat tier1.token
```

#### Tier 2:  
1. Copy the token and create a file ``tier1.token``.
2. Create the link from thei Tier 2 to Tier 1 site:
```
skupper link create ~/tier1.token
```

Now repeat this process to crate a link between the Tier 2 and Tier 3 sites:

#### Tier 2:
1. Generate a token.  
```
skupper token create ~/tier2.token
cat tier2.token
```

#### Tier 3:
1. Copy the token and create a file ``tier2.token``.
2. Create the link from the Tier 3 to Tier 2 site:  
```
skupper link create ~/tier2.token
```

### Tier 3:
1. Generate a token  
```
skupper token create ~/tier3.token
cat tier3.token
```

#### Base:
1. Copy the token and create a file ``tier3.token``.
2. Create the link from the Base to Tier 3 site:  
```
skupper link create ~/tier3.token
```

Observe the network status in the Service Interconnect Console:

   <img src=./docs/img/s1-links.png alt="Console" width="700" height="500">


You can also view the network topology from the command line:  
```
$ skupper network status

Sites:
├─ [local] 132f381b-aa11-440c-a0e1-eb2300050096(bryon-full-s1) 
│  │ namespace: bryon-full-s1
│  │ site name: on-prem
│  │ version: 1.5.3
│  ╰─ Linked sites:
│     ╰─ dc7a5c3e-f4b5-4a58-8eee-695a0d9c90de(bryon-tier3)
│        direction: outgoing
├─ [remote] dc7a5c3e-f4b5-4a58-8eee-695a0d9c90de(bryon-tier3) 
│  │ namespace: bryon-tier3
│  │ site name: tier-3
│  │ version: 1.5.3
│  ╰─ Linked sites:
│     ├─ 3fee8ed7-2f0e-4632-bc50-194952d1aae9(bryon-tier2)
│     │  direction: outgoing
│     ╰─ 132f381b-aa11-440c-a0e1-eb2300050096(bryon-full-s1)
│        direction: incoming
├─ [remote] 3fee8ed7-2f0e-4632-bc50-194952d1aae9(bryon-tier2) 
│  │ namespace: bryon-tier2
│  │ site name: tier-2
│  │ version: 1.5.3
│  ╰─ Linked sites:
│     ├─ dc7a5c3e-f4b5-4a58-8eee-695a0d9c90de(bryon-tier3)
│     │  direction: incoming
│     ╰─ 5f801c01-f0e6-4e68-b674-d61782b1701d(bryon-tier1)
│        direction: outgoing
╰─ [remote] 5f801c01-f0e6-4e68-b674-d61782b1701d(bryon-tier1) 
   │ namespace: bryon-tier1
   │ site name: tier-1
   │ version: 1.5.3
   ╰─ Linked sites:
      ╰─ 3fee8ed7-2f0e-4632-bc50-194952d1aae9(bryon-tier2)
         direction: incoming
```

You can also view the link status of each site. E.g. In Tier 3


```
skupper link status

Links created from this site:

	 Link link1 is connected

Current links from other sites that are connected:

	 Incoming link from site 132f381b-aa11-440c-a0e1-eb2300050096 on namespace bryon-full-s1
```
Here you can see one inbound link and one outbound link.


### Step 6: Deploy Microservices
Ensure that Tier 2 and Tier 3 namespaces are devoid of microservices by running `oc get pod`. Everything should be bare.
Clone the Online Boutique microservices demo repository into the Tier 2 and 3 clusters:

```
git clone https://github.com/Multi-Cluster/RHSI-Hackathon.git
```

Navigate to the kustomize directory:

```
cd RHSI-Hackathon/online-boutique/Openshift
```

Apply the overlays dir applicable to the Tier 2 cluster:

```
oc apply -f middleware --recursive
```

Verify that the pods are deployed in the Tier 2 cluster:

```
$ oc get pod
NAME                                          READY   STATUS    RESTARTS   AGE
adservice-64c764d94b-tcvkz                    1/1     Running   0          50s
cartservice-5cc8799bb5-smxgv                  1/1     Running   0          50s
checkoutservice-57c7c76b4-bxwzs               1/1     Running   0          50s
currencyservice-7f74bd4f76-xqn5s              1/1     Running   0          50s
productcatalogservice-849757575b-5plpp        1/1     Running   0          50s
recommendationservice-667ff888b-wszrs         1/1     Running   0          50s
redis-cart-6cf65677c4-h8scq                   1/1     Running   0          50s
shippingservice-5c4865ddc8-fslqw              1/1     Running   0          50s
skupper-prometheus-867f57b89-cksgb            1/1     Running   0          17h
skupper-router-5c8c764568-gglg9               2/2     Running   0          17h
skupper-service-controller-856db7d6c7-bf7jj   2/2     Running   0          17h
```

Repeat the same for Tier 3.

```
$ oc apply -f payments --recursive
service/emailservice created
service/paymentservice created
deployment.apps/emailservice created
deployment.apps/paymentservice created
```

Verify the correct pods have been deployed

```
$ oc get pod
NAME                                          READY   STATUS    RESTARTS   AGE
emailservice-6c996685db-r9xc6                 1/1     Running   0          71s
paymentservice-8d5c98486-wqgv2                1/1     Running   0          71s
skupper-prometheus-867f57b89-xw2zc            1/1     Running   0          17h
skupper-router-f94cff94d-hmkx5                2/2     Running   0          17h
skupper-service-controller-5c8db58cb5-sglfc   2/2     Running   0          17
```

### Step 7: Expose Services via Skupper
Expose each microservice deployment in its respective namespace/cluster using Skupper.

Tier 2 namespace:

```
skupper expose deployment adservice && \
skupper expose deployment cartservice && \
skupper expose deployment checkoutservice && \
skupper expose deployment currencyservice && \
skupper expose deployment productcatalogservice && \
skupper expose deployment recommendationservice && \
skupper expose deployment redis-cart && \
skupper expose deployment shippingservice
```

Tier 3 namespace:

```
skupper expose deployment emailservice && \
skupper expose deployment paymentservice
```

Observe the changes in the Services annotations.

```
$ oc get svc emailservice -o yaml | grep selector -A 4
  selector:
    application: skupper-router
    skupper.io/component: router
  sessionAffinity: None
  type: ClusterIP
```

### Step 8: Verify Mesh Spanning
Ensure that the microservice mesh spans across all three clusters. You should just be able to run oc get svc from any cluster/namespace and see all of them visible.

We’re now going to effectively decomm the On-Prem namespace. Expose the frontend service in the On-Prem namespace and scale down all microservices in the original On-Prem namespace to 0 replicas. We don’t however want to scale down the loadgenerator or frontend running in the background!

```
export TEAMNAME_ONPREM_NS="<your-team>-onprem" && \
skupper expose deployment frontend -n ${TEAMNAME_ONPREM_NS} && \
oc scale --replicas=0 deployment adservice -n ${TEAMNAME_ONPREM_NS} && \
oc scale --replicas=0 deployment cartservice -n ${TEAMNAME_ONPREM_NS} && \
oc scale --replicas=0 deployment checkoutservice -n ${TEAMNAME_ONPREM_NS} && \
oc scale --replicas=0 deployment currencyservice -n ${TEAMNAME_ONPREM_NS} && \
oc scale --replicas=0 deployment emailservice -n ${TEAMNAME_ONPREM_NS} && \
oc scale --replicas=0 deployment paymentservice -n ${TEAMNAME_ONPREM_NS} && \
oc scale --replicas=0 deployment productcatalogservice -n ${TEAMNAME_ONPREM_NS} && \
oc scale --replicas=0 deployment recommendationservice -n ${TEAMNAME_ONPREM_NS} && \
oc scale --replicas=0 deployment redis-cart -n ${TEAMNAME_ONPREM_NS} && \
oc scale --replicas=0 deployment shippingservice -n ${TEAMNAME_ONPREM_NS}
```

Visit the frontend URL from the On-Prem namespace and perform actions like adding items to the cart and making payments to verify functionality. 

From here, you should be able to go and Add to Cart and Place an Order.

#### Screenshots

| Home Page                                                                                                         | Checkout Screen                                                                                                    |
| ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| [![Screenshot of boutique-landing](/docs/img/boutique_landing.png)](/docs/img/boutique_landing.png) | [![Screenshot of checkout screen](/docs/img/placed_order.png)](/docs/img/placed_order.png) |

### Step 9: Migrate Frontend Service
Prepare for the migration of the frontend service to another namespace within the SAME (on-prem) cluster. 

**NOTE**:  While the conceptual idea involves deploying to another cluster, the practical implementation will utilize another namespace named `tier1`.

We don’t intend to decommission the route; however, from the original ON-PREM namespace. The external LB will continue to serve traffic to this namespace to the route.

Create the new Tier 1 namespace.

```
oc new-project <your-team>>-tier1-s1
```

Deploy the frontend via kustomize

```
oc apply -f frontend --recursive
```

Follow the same steps as for other clusters (Steps 4 & 5): initialize Skupper in addition to creating tokens and links.

For the link connection we want to create the token in On-Prem, and create the link from the Tier 1 namespace.

You should now have two connected namespaces will you run `skupper link status` from the original On Prem namespace.

```
$ skupper link status

Links created from this site:

	 There are no links configured or connected

Current links from other sites that are connected:

	 Incoming link from site 9f5e5d3c-2a65-4fa0-ad3d-01ad389f58e2 on namespace ${TIER1_FRONTEND_NS}
	 Incoming link from site 78884fa3-f77e-48e2-85f6-e1d920edf8c6 on namespace ${TIER2_NS}
```

Now we want to expose the frontend service in the Tier 1 namespace via Skupper and then finish off our decommissioning activities in the On-Prem namespace by scaling down the originating `frontend` workload.

```
export TEAMNAME_ONPREM_NS="<your-team>>-onprem" && \
export TEAMNAME_TIER1_NS="<your-team>>-tier1-s1" && \
skupper expose deployment frontend -n ${TEAMNAME_TIER1_NS} && \
oc scale --replicas=0 deployment frontend -n ${TEAMNAME_ONPREM_NS} 
```

You should now be able to visit the original Frontend route and verify its operation.
