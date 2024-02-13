# Use Online Boutique with Kustomize

This page contains instructions on deploying variations of the [Online Boutique]


## Deploy Online Boutique with Kustomize

1. From the root folder of this repository, navigate to the `Openshift/` directory.

    ```bash
    cd Openshift/
    ```

2. Apply the templates under (`Openshift/`).

    ```bash
    oc apply -f . --recursive
    ```

3. Wait for all Pods to show `STATUS` of `Running`.

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

4. Access the web frontend in a browser using the frontend's `Route`.

    ```bash
    oc get route frontend -o jsonpath='{.spec.host}'
    ```

