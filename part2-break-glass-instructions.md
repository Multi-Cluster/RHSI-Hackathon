# Red Hat Service Interconnect - February APAC Hackathon
# Scenario 1 - Service Sync Disabled
- [Red Hat Service Interconnect - February APAC Hackathon](#red-hat-service-interconnect---february-apac-hackathon)
- [Scenario 1 - Service Sync Disabled](#scenario-1---service-sync-disabled)
  - [Pre-requisites](#pre-requisites)
  - [Step 1: Inventory of "Monoliths" Existing Pods](#step-1-inventory-of-monoliths-existing-pods)
  - [Step 2: Access the Three Target OpenShift Clusters](#step-2-access-the-three-target-openshift-clusters)
  - [Step 3: Create the namespaces](#step-3-create-the-namespaces)
  - [Clone the code base](#clone-the-code-base)
  - [current state](#current-state)
  - [End state](#end-state)
  - [Migration Steps](#migration-steps)
  - [Step 4: Skupper Initialisation](#step-4-skupper-initialisation)
      - [On Premises (Base Application)](#on-premises-base-application)
      - [AWS-MELB (Tier 1)](#aws-melb-tier-1)
      - [AWS-SYD (Tier 2)](#aws-syd-tier-2)
      - [AWS-SING (Tier 3)](#aws-sing-tier-3)
  - [Step 5: Create the Service Interconnect Network](#step-5-create-the-service-interconnect-network)
    - [**Concepts**](#concepts)
    - [**Tier1 cluster**](#tier1-cluster)
    - [**OnPrem cluster**](#onprem-cluster)
    - [**Tier2 cluster**](#tier2-cluster)
    - [**Tier3 cluster**](#tier3-cluster)
    - [Step 6: Deploy Microservices](#step-6-deploy-microservices)
    - [Tier2 Cluster](#tier2-cluster-1)
    - [Tier1 Cluster](#tier1-cluster-1)

## Pre-requisites

   1. Skupper cli - Download it [**here**](https://skupper.io/releases/index.html)
   2. oc cli Download it [**here**](http://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.14.0/openshift-client-linux-4.14.0.tar.gz)
   3. Access to openshift clusters 
## Step 1: Inventory of "Monoliths" Existing Pods
Begin by reviewing the deployment that was provided for you.

Replace ``<your-team>`` with the team name provided by your facilitator.  
Using the  project ```<yourteam>-base-s2``` on the ```on-prem``` cluster, get all the pods.

```
oc login -u <your-team> <cluster url>

oc project <yourteam>-base-s2

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
E.g. http://frontend-team1-base-s2.apps.cluster-2txjp.2txjp.sandbox2634.opentlc.com  


## Step 2: Access the Three Target OpenShift Clusters

***In separate terminal windows***, login to the ```AWS MELB``` and ```AWS SYD``` and ```AWS SING``` OpenShift (OCP) clusters. E.g.:  

   ![Front screen](./docs/img/s1-login.png)  


The application will be deployed into three tiers distributed across the three clusters. The project/cluster mapping is:  
  | Project | Cluster | Notes |
  |---------|---------|-------|
  | < your-team >-base-s2 | ON-PREM | Full single-namespace application |
  | < your-team >-tier1-s2 | AWS MELB | Front end services |
  | < your-team >-tier2-s2 | AWS SYD | Cart, Product Catalog, Currency, Shipping, Checkout, Recommendation, Ad, and Redis cache |
  | < your-team >-tier3-s2 | AWS SING | Payment and Email services. | 


## Step 3: Create the namespaces

Because we will be progressively migrating and avoiding application outages, we must first deploy Service Interconnect into each project.  

Using the naming convention in the table above, create the namespaces in each cluster. E.g. on the ``AWS MELB`` cluster you would enter this command:  

```
oc new-project <your-team>-tier1-s2
```

## Clone the code base

Code for deploying the online boutique is in [this](https://github.com/Multi-Cluster/RHSI-Hackathon) git repo
```
git clone https://github.com/Multi-Cluster/RHSI-Hackathon.git

```
   

## current state

  ```mermaid
  %%{init: {"flowchart": {"htmlLabels": false}} }%%
  flowchart LR
      A[["On-Prem cluster
        -------------------
        All microservices
        deployed here"]]
      A  
    
  ```

## End state

  ```mermaid
  %%{init: {"flowchart": {"htmlLabels": false}} }%%
  flowchart LR
      A[["On-Prem cluster
        -------------------
        Decomissioned"]]
        
      B[["Tier1 cluster
        -------------------
        Frontend microservices
        deployed here"]]

      C[["Tier2 cluster
        -------------------
        middleware microservices
        deployed here"]]

      D[["Tier3 cluster
        -------------------
        Payments microservices
        deployed here"]]

    B <--> C <--> D
       
    
  ```

## Migration Steps
## Step 4: Skupper Initialisation
Once you have created each project, install Service Interconnect.
#### On Premises (Base Application)
1. Install RHSI in the application namespace on the OnPrem cluster

```
export KUBECONFIG=~/onprem-cluster

oc login

oc project rmallam-base

```

```
skupper init --enable-flow-collector --enable-console --enable-service-sync=false --site-name base  --console-user admin --console-password password

```
#### AWS-MELB (Tier 1)
2. Install RHSI in the frontend namespace on the Tier1 cluster

Create a namespace with a suffix of your team name. 

```
export KUBECONFIG=~/tier1-cluster

oc login

oc new-project rmallam-frontend

```

```
skupper init --enable-flow-collector --enable-console --enable-service-sync=false --site-name frontend --console-user admin --console-password password

```
#### AWS-SYD (Tier 2)
3. Install RHSI in the middleware namespace on the Tier2 cluster

Create a namespace with a suffix of your team name. 

```
export KUBECONFIG=~/tier2-cluster

oc login

oc new-project rmallam-middleware

```

```
skupper init --enable-flow-collector --enable-console --enable-service-sync=false --site-name middleware --console-user admin --console-password password

```
#### AWS-SING (Tier 3)
3. Install RHSI in the middleware namespace on the Tier3 cluster

Create a namespace with a suffix of your team name.

```
export KUBECONFIG=~/tier3-cluster

oc login 

oc new-project rmallam-payments

```

```
skupper init --enable-flow-collector --enable-console --enable-service-sync=false --site-name payments --console-user admin --console-password password

```

**Note:** From this point forward we will refer to each project as ```Base```, ```Tier 1```, ```Tier 2```, or ```Tier 3```.

You have now installed Service Interconnect. You can access the Service Interconnect console through the route. E.g. In the ```Base``` project, 
```
oc get route skupper
```

Paste the route from above into your browser.  The username/password is: ``admin/password``. Keep this tab open and use it to observe what is happening in the network as you proceed through the steps.

   <img src=./docs/img/s1-console.png alt="Console" width="700" height="400">

## Step 5: Create the Service Interconnect Network

### **Concepts**

1. Each namespaces where skupper is deployed is called a **SITE**.
2. Communication between sites is established by **LINKS**
3. **TOKENS** are exchanged between sites to Trust and establish **LINKS**
4. **TOKENS** can be generated on any site and exchanged with other sites to establish **LINKS**
5. LINK are UNI-DIRECTIONAL but the exchange of data between sites is  BI-DIRECTIONAL. 
6. As a best practise, Always establish link from a MOST TRUSTED ZONE/CLUSTER to a LESSER TRUESTED ZONE/CLUSTER. In our example Tier3 cluster is the most trusted, so the link originates from here.
```mermaid
%%{init: {"flowchart": {"htmlLabels": false}} }%%
graph LR
    A["Cluster1
      ---------
      Deploy Skupper
      create token"]
    B["Cluster2
      ---------
      Deploy skupper
      Get token from cluster1 to create link"]
    B  -- skupper link --> A
    A  <==data==> B
```


### **Tier1 cluster**
1. create a token on the tier1 cluster

```
export KUBECONFIG=~/tier1-cluster

oc project rmallam-frontend

skupper token create frontend.yaml --uses=2 

# this will create a file called frontend.yaml in the current working directory
 
```
### **OnPrem cluster**
2. Use the token generated to create a link with on prem cluster. copy the frontend.yaml to your current working directory if not already available.

```
export KUBECONFIG=~/onprem-cluster

oc apply -f frontend.yaml -n rmallam-base

```
```mermaid
%%{init: {"flowchart": {"htmlLabels": false}} }%%
graph LR
    A["On-Prem cluster
       All microservices
       deployed here"]
    B["Tier1 Cluster
       Frotend goes here"]
    A  -- skupper link --> B
    A  <==data==> B
   
```
### **Tier2 cluster**
3. use the same token to create a link from tier2

```
export KUBECONFIG=~/tier2-cluster

oc apply -f frontend.yaml -n rmallam-middleware

```
```mermaid
graph LR
    
    A[ONPrem]  -- skupper link --> B[Tier1 Cluster]
    A[ONPrem]  <== data ==> B[Tier1 Cluster]
    B[Tier1 Cluster] <== data ==> C[Tier2 Cluster]
    C[Tier2 Cluster] -- skupper link --> B[Tier1 Cluster]
```

4. Create a token on middleware namespace in Tier2 cluster to establish a link with Payments namespace in Tier3 cluster

```
export KUBECONFIG=~/tier2-cluster

skupper token create middleware.yaml

```
### **Tier3 cluster**
5. Use the middleware.yaml token created in the previous step to establish a link from payments namespace in tier3 cluster to middleware namespace in tier2 cluster

```
export KUBECONFIG=~/tier3-cluster

oc apply -f middleware.yaml -n rmallam-payments

```
```mermaid
graph LR
    
    A[ONPrem]  -- skupper link --> B[Tier1 Cluster]
    A[ONPrem]  <== data ==> B[Tier1 Cluster]
    C[Tier2 Cluster] -- skupper link --> B[Tier1 Cluster]
    B[Tier1 Cluster] <== data ==> C[Tier2 Cluster]
    D(Tier3 Cluster) -- skupper link --> C(Tier2 Cluster)
    C(Tier2 Cluster)<== data ==> D(Tier3 Cluster)
    

```
### Step 6: Deploy Microservices


1. Clone the Online Boutique microservices demo repository into the Tier 1, Tier 2, and Tier 3 workstations (bastions):  
    ```
    git clone https://github.com/Multi-Cluster/RHSI-Hackathon.git
    ```

2. starting with the most restricted applications first. payments and email service should go onto payments namespace in tier3 cluster. From the root folder of this repository, navigate to the `online-boutique/Openshift/` directory and apply the mainfests.

    ```bash
    cd online-boutique/Openshift/
    export KUBECONFIG=~/tier3-cluster
    oc apply -f payments
    ```

    ```

    service/emailservice created
    service/paymentservice created
    deployment.apps/emailservice created
    deployment.apps/paymentservice created
    ```
    ```
    oc get pods
    emailservice-5766bd4fc8-nnngf                1/1     Running   0          60s
    paymentservice-c6f48ffb6-zv8jv               1/1     Running   0          60s
    skupper-prometheus-59db49845c-xzrdr          1/1     Running   0          4h13m
    skupper-router-6548887ddf-mpscl              2/2     Running   0          4h13m
    skupper-service-controller-9c66bf75f-4ffc4   2/2     Running   0          4h13m
    ```

3. expose the payment and email services via skupper.
   

   ```
   skupper expose deployment paymentservice

   deployment paymentservice exposed as paymentservice
   ```
   
   ```
   skupper expose deployment emailservice

   deployment emailservice exposed as emailservice
   ```

### Tier2 Cluster

1. The middleware services we are deploying now will interact with payments and email service using the service names but they are not available here because the skupper is deployed with service sync disabled. We have to create them manually using the commands below.
   ```
   export KUBECONFIG=~/tier2-cluster
   ```
  ```
  skupper service create paymentservice --protocol tcp 50051

  skupper service create emailservice --protocol tcp 8080

  ```

2. From the root folder of this repository, navigate to the `online-boutique/Openshift/` directory and apply the mainfests.

    ```bash
    cd online-boutique/Openshift/
   
    ```
    ```
    oc apply -f middleware
    ```
    ```
    service/adservice created
    service/cartservice created
    service/checkoutservice created
    service/currencyservice created
    service/productcatalogservice created
    service/recommendationservice created
    service/redis-cart created
    service/shippingservice created
    deployment.apps/adservice created
    deployment.apps/cartservice created
    deployment.apps/checkoutservice created
    deployment.apps/currencyservice created
    deployment.apps/productcatalogservice created
    deployment.apps/recommendationservice created
    deployment.apps/redis-cart created
    deployment.apps/shippingservice created
    ```
    ```
    $oc get pods
    ```
    ```
    NAME                                         READY   STATUS    RESTARTS   AGE
    adservice-68448666d6-skvb2                   1/1     Running   0          34s
    cartservice-5fdd4bf56f-5vd5c                 1/1     Running   0          33s
    checkoutservice-f87cf5864-gz4rv              1/1     Running   0          33s
    currencyservice-6cf5b4d57b-vcpx9             1/1     Running   0          33s
    productcatalogservice-595b7b5884-47rtj       1/1     Running   0          32s
    recommendationservice-5d8b99449d-rdk42       1/1     Running   0          32s
    redis-cart-59c4c557db-nh4nm                  1/1     Running   0          32s
    shippingservice-64cf4f6998-gnkqn             1/1     Running   0          31s
    skupper-prometheus-59db49845c-xzrdr          1/1     Running   0          5h4m
    skupper-router-6548887ddf-mpscl              2/2     Running   0          5h4m
    skupper-service-controller-9c66bf75f-4ffc4   2/2     Running   0          5h4m
    ```
  
2. Expose all the services deployed via skupper
  ```
  $for i in adservice cartservice checkoutservice currencyservice productcatalogservice recommendationservice redis-cart shippingservice; do skupper expose deployment $i; done
  ```
  ```
  deployment adservice exposed as adservice
  deployment cartservice exposed as cartservice
  deployment checkoutservice exposed as checkoutservice
  deployment currencyservice exposed as currencyservice
  deployment productcatalogservice exposed as productcatalogservice
  deployment recommendationservice exposed as recommendationservice
  deployment redis-cart exposed as redis-cart
  deployment shippingservice exposed as shippingservice
  ```

### Tier1 Cluster

1. Like we did in tier2 cluster, all the middleware services deployed in tier2 cluster will not be visible to frontend cluster, Hence we will create them using the skupper cli.
  ```
  export KUBECONFIG=~/tier1-cluster
  ```
  ```
  skupper service create adservice --protocol tcp 9555
  skupper service create cartservice --protocol tcp 7070
  skupper service create checkoutservice --protocol tcp 5050
  skupper service create productcatalogservice --protocol tcp 3550
  skupper service create recommendationservice --protocol tcp 8080
  skupper service create redis-cart --protocol tcp 6379
  skupper service create shippingservice --protocol tcp 50051
  skupper service create currencyservice --protocol tcp 7000
  ```

2.  From the root folder of this repository, navigate to the `online-boutique/Openshift/` directory and apply the mainfests.

    ```bash
    cd online-boutique/Openshift/
    oc apply -f frontend 
    ```
    ```
    service/frontend created
    deployment.apps/frontend created
    route.route.openshift.io/frontend created
    ```
    ```
    $oc get pods
    ```
    ```
    NAME                                         READY   STATUS    RESTARTS   AGE
    frontend-7b65d55cbd-ff5ws                    1/1     Running   0          48s
    skupper-prometheus-59db49845c-xzrdr          1/1     Running   0          5h13m
    skupper-router-6548887ddf-mpscl              2/2     Running   0          5h13m
    skupper-service-controller-9c66bf75f-4ffc4   2/2     Running   0          5h13m
    ```
    ```
    skupper expose deployment frontend
    ```

    ### ONPrem cluster

    1. expose frontend via skupper

  ```
  export KUBECONFIG=~/onprem-cluster
  ```
  ```
  skupper expose deployment frontend
  ```
    2. Scale down all the pods and check if the exisitng route is still working 

  ```
  for i in adservice cartservice checkoutservice currencyservice productcatalogservice recommendationservice redis-cart shippingservice emailservice paymentservice; do oc scale deploy $i --rep
  licas=0 ;done
  ```

    ```bash
    oc get route frontend -o jsonpath='{.spec.host}'
    ```