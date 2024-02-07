# Use Online Boutique with Kustomize

This page contains instructions on deploying variations of the [Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo) sample application using [Kustomize](https://kustomize.io/). Each variations is designed as a [**Kustomize component**](https://github.com/kubernetes-sigs/kustomize/blob/master/examples/components.md), so multiple variations can be composed together in the deployment.

## What is Kustomize?

Kustomize is a Kubernetes configuration management tool that allows users to customize their manifest configurations without duplication. Its commands are built into `kubectl` as `apply -k`. More information on Kustomize can be found on the [official Kustomize website](https://kustomize.io/).

## Prerequisites

Optionally, [install the `kustomize` binary](https://kubectl.docs.kubernetes.io/installation/) to avoid manually editing a `kustomization.yaml` file. Online Boutique's instructions will often use `kustomize edit` (like `kustomize edit add component components/some-component`), but you can skip these commands and instead add components manually to the [`/kustomize/kustomization.yaml` file](/kustomize/kustomization.yaml).

You need to have a Kubernetes cluster where you will deploy the Online Boutique's Kubernetes manifests. To set up a GKE (Google Kubernetes Engine) cluster, you can follow the instruction in the [root `/README.md`](/).

## Deploy Online Boutique with Kustomize

1. From the root folder of this repository, navigate to the `kustomize/` directory.

    ```bash
    cd kustomize/
    ```

1. See what the default Kustomize configuration defined by `kustomize/kustomization.yaml` will generate (without actually deploying them yet).

    ```bash
    kubectl kustomize .
    ```

1. Apply the default Kustomize configuration (`kustomize/kustomization.yaml`).

    ```bash
    kubectl apply -k .
    ```

1. Wait for all Pods to show `STATUS` of `Running`.

    ```bash
    kubectl get pods
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

1. Access the web frontend in a browser using the frontend's `Route`.

    ```bash
    oc get route frontend -o jsonpath='{.spec.host}'
    ```

