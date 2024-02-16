# Deploying the Online Boutique

This page contains instructions on deploying The Online Boutique application into a single namespace.

## Environment Overview

```TBC```

## Accessing the Environment

Before you start you will need your facilitator to provide the user ids and passwords for each system in the environment.

```TBC```


## Getting Set Up to Start the Hackathon

### Deploy Online Boutique

To get set for the hackathon you should start by deploying the entire application into a singke namespace on the ``Tier 1`` cluster.

#### Log on to the Tier 1 Bastion Server

```TBC```

```ssh lab-user@<insert url>```

#### Deploy the Application

1. From the root folder of this repository, navigate to the `online-boutique/Openshift/` directory.

    ```bash
    cd online-boutique/Openshift/
    ```

2. Login to the on-prem cluster and create your namespace as per the advised naming convention.

    ```bash
    oc new-project teamname-onprem
    ```
   
3. Apply the templates under (`online-boutique/Openshift/`).

    ```bash
    oc apply -f . --recursive
    ```

4. Wait for all Pods to show `STATUS` of `Running`.

    ```bash
    oc get pods
    ```

    The output should be similar to the following:

    ```terminal
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
    shippingservice-6ccc89f8fd-v686r         1/1     Running   0          2m58s
    ```

    _Note: It may take 2-3 minutes before the changes are reflected on the deployment._

5. Access the web frontend in a browser using the frontend's `Route`.

    ```bash
    oc get route frontend -o jsonpath='{.spec.host}'
    ```

