## Red Hat Service Interconnect - February APAC Hackathon

## Scenario 1 - Service Sync ENABLED

### Step 1: Inventory of Existing Pods
Begin by assessing the pods deployed within the designated namespace in the on-premises cluster. The following pods are currently set up:

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

### Step 2: Access Tiered OpenShift Clusters
Login to the Tier 2 and Tier 3 OpenShift (OCP) clusters hosted in the cloud. Each services is destined for either the Tier 2 or 3 cluster:

* **Tier 2 Cluster**: Cart, Product Catalog, Currency, Shipping, Checkout, Recommendation, Ad, and Redis cache.
* **Tier 3 Cluster**: Payment and Email services.

### Step 3: Create the namespaces

Create the following namespaces in each of the above clusters as per the set naming convention.

*Tier 2*

```
oc new-project teamname-tier2-s1
```

*Tier 3*

```
oc new-project teamname-tier3-s1
```

### Step 4: Skupper Initialization
Initialize Skupper in all clusters, including the on-premises one. Execute the following command:

```
skupper init --enable-console --enable-flow-collector
```

This command will deploy a single instance each of the Skupper router, service-controller, and Prometheus.

### Step 5: Mesh Generation
Create the mesh to establish peer networks between the clusters. We'll create two peer networks where On-Prem will trust Tier 2, and Tier 3 will trust Tier 2.

Since Service Sync is enabled, a transitional trust relationship will exist between On-Prem and Tier 3 clusters, ensuring that all services exposed via Skupper will be visible in each cluster/namespace.

#### Commands:

On-Prem: **Generate a token**.

```
skupper token create ~/onprem.token
```

Tier 2: **Copy the token and create a link using it.**

```
skupper link create ~/onprem.token
```

Tier 2: **Generate a token.**

```
skupper token create ~/tier2.token
```

Tier 3: **Copy the token and create a link using it.**

```
skupper link create ~/tier2.token
```

These should be the resulting outputs of `skupper link status` in each of the clusters

*Tier 1*

```
$ skupper link status


Links created from this site:


	 There are no links configured or connected


Current links from other sites that are connected:


	 Incoming link from site 78884fa3-f77e-48e2-85f6-e1d920edf8c6 on namespace ${NAMESPACE}
```

*Tier 2*

```
$ skupper link status


Links created from this site:


	 Link link1 is connected


Current links from other sites that are connected:


	 Incoming link from site ad0854aa-0a23-49bf-84ff-797e315e8619 on namespace ${NAMESPACE}
```

*Tier 3*

```
$ skupper link status


Links created from this site:


	 Link link1 is connected


Current links from other sites that are connected:


	 There are no connected links
```

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
export TEAMNAME_ONPREM_NS="teamname-onprem" && \
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
oc new-project teamname-tier1-s1
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
export TEAMNAME_ONPREM_NS="teamname-onprem" && \
export TEAMNAME_TIER1_NS="teamname-tier1-s1" && \
skupper expose deployment frontend -n ${TEAMNAME_TIER1_NS} && \
oc scale --replicas=0 deployment frontend -n ${TEAMNAME_ONPREM_NS} 
```

You should now be able to visit the original Frontend route and verify its operation.
