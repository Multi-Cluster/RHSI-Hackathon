# Migratate the online boutique to different openshift clusters

- [Migratate the online boutique to different openshift clusters](#migratate-the-online-boutique-to-different-openshift-clusters)
  - [Pre-requisites](#pre-requisites)
  - [Migration Steps](#migration-steps)
    - [Install RHSI](#install-rhsi)
  - [Connect/Link the sites](#connectlink-the-sites)
  - [Application migration](#application-migration)

## Pre-requisites

   1. Skupper cli - Download it [**here**](https://skupper.io/releases/index.html)
   2. oc cli Download it [**here**](http://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.14.0/openshift-client-linux-4.14.0.tar.gz)
   3. Access to openshift clusters 
   
## Migration Steps

### Install RHSI

1. Install RHSI in the application namespace on the OnPrem cluster

```
export kubeconfig=~/onprem-cluster

oc login

oc project rmallam-base

```

```
skupper init --enable-flow-collector --enable-console --enable-service-sync=false --site-name base

```

2. Install RHSI in the frontend namespace on the Tier1 cluster

Create a namespace with a suffix of your team name. 

```
export kubeconfig=~/tier1-cluster

oc login

oc new-project rmallam-frontend

```

```
skupper init --enable-flow-collector --enable-console --enable-service-sync=false --site-name frontend

```

3. Install RHSI in the middleware namespace on the Tier2 cluster

Create a namespace with a suffix of your team name. 

```
export kubeconfig=~/tier2-cluster

oc login

oc new-project rmallam-middleware

```

```
skupper init --enable-flow-collector --enable-console --enable-service-sync=false --site-name middleware

```

3. Install RHSI in the middleware namespace on the Tier3 cluster

Create a namespace with a suffix of your team name.

```
export kubeconfig=~/tier3-cluster

oc login 

oc new-project rmallam-payments

```

```
skupper init --enable-flow-collector --enable-console --enable-service-sync=false --site-name payments

```

## Connect/Link the sites

1. create a token on the tier1 cluster

```
export kubeconfig=~/tier1-cluster

oc project rmallam-frontend

skupper token create frontend.yaml --uses=2 

# this will create a file called frontend.yaml in the current working directory
 
```

2. Use the token generated to create a link with on prem cluster. copy the frontend.yaml to your current working directory if not already available.

```
export kubeconfig=~/onprem-cluster

oc apply -f frontend.yaml -n rmallam-base

```

3. use the same token to create a link from tier2

```
export kubeconfig=~/tier2-cluster

oc apply -f frontend.yaml -n rmallam-middleware

```

4. Create a token on middleware namespace in Tier2 cluster to establish a link with Payments namespace in Tier3 cluster

```
export kubeconfig=~/tier2-cluster

skupper token create middleware.yaml

```

5. Use the middleware.yaml token created in the previous step to establish a link from payments namespace in tier3 cluster to middleware namespace in tier2 cluster

```
export kubeconfig=~/tier2-cluster

oc apply -f middleware.yaml -n rmallam-payments

```

## Application migration

1. starting with the most restricted applications first. payments and email service should go onto payments namespace in tier3 cluster.

Update `kustomize/kustomization.yaml` to deploy only payments. the file should like below.

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
# - frontend
# - middleware
 - payments
# - loadgenerator

```
2. From the root folder of this repository, navigate to the `online-boutique/kustomize/` directory and apply the mainfests.

    ```bash
    cd online-boutique/kustomize/
   
    ```
    ```
    kubectl apply -k .
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



