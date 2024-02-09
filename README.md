## Red Hat Service Interconnect - February APAC Hackathon

### Scenario 1 - Service Sync ENABLED

As Baker's Bargain Barn embarks on the journey of migrating to the cloud, we recognize that our long-term business agility depends on this transition. One critical aspect of this migration involves our Online Boutique application. It's imperative that we achieve zero downtime during this process to ensure seamless operation for our users.

As you participate in this hackathon, remember that your primary goal is to migrate our Online Boutique microservice, spanning three clusters seamlessly - with ZERO DOWNTIME as you migrate! To aid in this endeavor, we'll be utilizing Skupper, a powerful tool for interconnecting services across Kubernetes clusters.

As a side note, we’ll be leveraging Locust, a powerful load testing engine, to monitor each team's application in the background. Locust will diligently observe for any deviations, particularly focusing on errors of the 400/500 type. It's imperative for each team participating in the hackathon to prioritize mitigating these errors to maintain a smooth user experience and avoid penalties to their overall score.

### Step 1: Inventory of Existing Pods
Begin by assessing the pods deployed within the designated namespace, base, in the on-premises cluster. The following pods are currently set up:

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
Login to the Tier 2 and Tier 3 OpenShift (OCP) clusters hosted in the cloud. Each cluster has distinct services allocated to it:

* Tier 2 Cluster: Cart, Product Catalog, Currency, Shipping, Checkout, Recommendation, Ad, and Redis cache.
* Tier 3 Cluster: Payment and Email services.

### Step 3: Skupper Initialization
Initialize Skupper in all clusters, including the on-premises one. Execute the following command:

```
skupper init --enable-console --enable-flow-collector
```

This command will deploy a single instance each of the Skupper router, service-controller, and Prometheus.

### Step 4: Mesh Generation
Create the mesh to establish peer networks between the clusters. We'll create two peer networks where Tier 1 will trust Tier 2, and Tier 3 will trust Tier 2.

Since Service Sync is enabled, a transitional trust relationship will exist between Tier 1 and Tier 3 clusters, ensuring that all services exposed via Skupper will be visible in each cluster/namespace.

#### Commands:

Tier 1: **Generate a token**.

```
skupper token create ~/tier1.token
```

Tier 2: **Copy the token and create a link using it.**

```
skupper link create ~/tier1.token
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

### Step 5: Deploy Microservices
Ensure that Tier 2 and Tier 3 namespaces are devoid of microservices.
Clone the Online Boutique microservices demo repository into the Tier 2 and 3 clusters:

```
git clone -b kustomize-rejig https://github.com/Multi-Cluster/RHSI-Hackathon.git --single-branch
```

Navigate to the kustomize directory:

```
cd RHSI-Hackathon/online-boutique/kustomize
```

Apply the overlays dir applicable to the Tier 2 cluster:

```
oc apply -k overlays/tier2
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
$ oc apply -k overlays/tier3
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

### Step 6: Expose Services via Skupper
Expose each microservice deployment in its respective namespace/cluster using Skupper.

Example for Tier 3 namespace:

```
skupper expose deployment emailservice 
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

### Step 7: Verify Mesh Spanning
Ensure that the microservice mesh spans across all three clusters. You should just be able to run oc get svc from any cluster/namespace and see all of them visible.

Visit the frontend URL from the base namespace and perform actions like adding items to the cart and making payments to verify functionality. 

From here, you should be able to go and Add to Cart and Place an Order.

### Screenshots

| Home Page                                                                                                         | Checkout Screen                                                                                                    |
| ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| [![Screenshot of boutique-landing](/docs/img/boutique_landing.png)](/docs/img/boutique_landing.png) | [![Screenshot of checkout screen](/docs/img/placed_order.png)](/docs/img/placed_order.png) |

### Step 8: Migrate Frontend Service
Prepare for the migration of the frontend service to another namespace within the same cluster. We don’t intend to decomm the route; however, from the original base namespace. The external LB will continue to serve traffic to this namespace to the route.

Create the new namespace called ‘frontend’

```
oc new-project will-frontend
```

Deploy the frontend via kustomize

```
oc apply -k overlays/tier1
```

Follow the same steps as for other clusters (Steps 3, 4 & 6): initialize Skupper, create tokens and links, deploy frontend service via kustomize, and expose it via Skupper.

You should now have two connected namespaces will you run `skupper link status` from the original base namespace.

```
$ skupper link status

Links created from this site:

	 There are no links configured or connected

Current links from other sites that are connected:

	 Incoming link from site 9f5e5d3c-2a65-4fa0-ad3d-01ad389f58e2 on namespace ${TIER1_FRONTEND_NS}
	 Incoming link from site 78884fa3-f77e-48e2-85f6-e1d920edf8c6 on namespace ${TIER2_NS}
```

We’re now going to effectively decomm the base namespace. Scale down all microservices in the original ‘base’ namespace to 0 replicas. We also don’t want to scale down the loadgenerator running in the background!

```
oc scale --replicas=0 deployment -n will-base --selector='!skupper.io/component,!app=loadgenerator'
```

Finally, update the original route to reflect the changes:

```
oc patch route frontend -n ${NAMESPACE} --type='json' -p='[{"op": "replace", "path": "/spec/port/targetPort", "value": "'$(oc get svc frontend -o=jsonpath='{.spec.ports[0].name}')'"}]'
```
