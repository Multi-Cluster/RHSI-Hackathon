# Red Hat Service Interconnect - February APAC Hackathon

Baker's Bargain Barn online retail website requires restructuring its architecture for scalability and security. The migration must ensure ZERO SERVICE DISRUPTION and refrain from altering application code or design. The frontend service relocates to Tier1 Cluster, while Payments and Email services migrate to the most secure cluster (Tier3). The remainder of the microservices should be destined for the Tier2 cluster. 

## Scenario 1 

Requirements:

1. Zero service disruption throughout the migration (outages will be monitored for)
2. Naming of namespaces follows the convention of prefixing team names to all created namespaces, with tier-specific designations (e.g., Teamname-tier1-s1 for Tier1 Cluster etc.)
3. No changes to the application code and/or K8s manifests
4. Deploy to three clusters where ALL services are visible to each other (**HINT:** cast your eyes to the `service-sync-enabled` flag as part of the `skupper` CLI)
5. Maintain the `frontend` route should still remain in the on-prem namespace

The objective is to progressively migrate microservices to different cloud VPCs while maintaining functionality. 

## Documentation

The following documentation matrix will lead you to important information to achieve the Hackathon's end goal. Running `skupper --help` will also give you plenty of direction. 

| Topic                               | Documentation Link                                    |
|-------------------------------------|-------------------------------------------------------|
| Install Skupper                     | [Documentation](https://skupper.io/install/index.html) |
| Working with Tokens                 | [Documentation](https://skupper.io/docs/cli/tokens.html)  |
| Using the Skupper Console         | [Documentation](https://skupper.io/docs/console/index.html) |
| Hello World Example               | [Documentation](https://skupper.io/start/index.html)  |

## Scenario 2

Now both functionality and **security** are of importance to the hybrid architecture of your Online Boutique. 

Requirements:

1. Zero service disruption throughout the migration (outages will be monitored for)
2. Naming of namespaces follows the convention of prefixing team names to all created namespaces, with tier-specific designations (e.g., Teamname-tier1-s2 for Tier1 Cluster etc.)
3. No changes to the application code and/or K8s manifests
4. Deploy to three clusters with restricted visibility of services, following a trust relationship where:

   - Tier2 trusts Tier1
   - Tier3 trusts Tier2
  
5. Migrate the route to the Tier1 namespace (i.e. both the workload and the route should now reside in the same namespace).
## Documentation

| Topic                               | Documentation Link                                    |
|-------------------------------------|-------------------------------------------------------|
| Disabling service sync                | [Documentation](https://skupper.io/docs/cli/tokens.html)  |
| Skupper service create              | [Documentation](https://skupper.io/docs/cli/index.html#exposing-services-on-the-service-network-from-a-namespace) |


## Scenario 3 (BONUS)

DO NOT DELETE what you've created in Scenario 2. This is an extension of that scenario's end product.

Requirements:

1. Update your Route 53 hosted zone with a CNAME record to point to the Frontend route


# Deploying the Online Boutique

This page contains instructions on deploying The Online Boutique application into a single namespace.

## Environment Overview
This challenge makes use of four OpenShift Clusters. 

The application is a traditional 3-tier app but all three tiers are currently deployed into a single namespace on the on-premises cluster.


  ```mermaid
  %%{init: {"flowchart": {"htmlLabels": false}} }%%
  flowchart LR
      A[["On-Prem cluster  
      (Singapore)
        -------------------
        Full Single-Namespace Application "]]
```

The mission is to progressively migrate the application to three different clusters that are hosted in different geographies.

```mermaid  %%{init: {"flowchart": {"htmlLabels": false}} }%%
  flowchart LR
      B[["Tier1 cluster 
      (AWS Melbourne)
        -------------------
        Frontend microservices"]]

      C[["Tier2 cluster  
      (AWS Sydney)
        -------------------
        middleware microservices"]]

      D[["Tier3 cluster  
      {AWS Singapore)}
        -------------------
        Payments microservices"]]

    B --> C --> D    
  ```

Each cluster has a bastion host that you can use to work directly with the cluster. By SSHing to the Bastion you have pre-configured access to your OpenShift cluster, and the ``oc`` and ``skupper`` cli tools are already installed.

Using the Bastion hosts is completely optional, you can use your own terminal if you choose. This will mean that you need to the install ``skupper`` and ``oc`` cli tools on your laptop.

```mermaid  %%{init: {"flowchart": {"htmlLabels": false}} }%%
  flowchart

      A[["Base cluster 
      (AWS Melbourne)
        -------------------
        Frontend microservices"]]

      B[["Tier1 cluster 
      (AWS Melbourne)
        -------------------
        Frontend microservices"]]

      C[["Tier2 cluster  
      (AWS Sydney)
        -------------------
        middleware microservices"]]

      D[["Tier3 cluster  
      {AWS Singapore)}
        -------------------
        Payments microservices"]]


      E[["RHEL Base Bastion 
      (AWS Melbourne)
        -------------------"]]

      F[["RHEL Bastion 1 
      (AWS Melbourne)
        -------------------"]]

      G[["RHEL Bastion 2 
      (AWS Sydney)
        -------------------"]]

      H[["RHEL Bastion 3
      {AWS Singapore)}
        -------------------"]]

      E --> A
      F --> B
      G --> C
      H --> D
    
  ```



## Git Repository Structure
The challenge will use a git repo that contains all of the deployment artifacts that you will need.  
```
.
├── docs
├── images                                         <= Images used in the documentation
├── online-boutique
│   └── Openshift
│       ├── tier1                                  <= All deployment artifacts for Tier 1 of the application
│       │   └── frontend.yaml
│       ├── loadgenerator
│       │   └── loadgenerator.yaml
│       ├── tier2                                  <= All deployment artifacts for Tier 1 of the application
│       │   ├── adservice.yaml
│       │   ├── cartservice.yaml
│       │   ├── checkoutservice.yaml
│       │   ├── currencyservice.yaml
│       │   ├── productcatalogservice.yaml
│       │   ├── recommendationservice.yaml
│       │   ├── redis.yaml
│       │   └── shippingservice.yaml
│       └── tier3                                  <= All deployment artifacts for Tier 1 of the application
│           ├── emailservice.yaml
│           └── paymentservice.yaml
├── README.md
└── scripts                                        <= Handy scripts to run oc in different terminals on a laptop
```

## Accessing the Environment


Before you start you will need your facilitator to provide the user ids and passwords for each system in the environment.

You can either use the bastion provided above or use your local machine for the hackathon. Bastion will have all the required softwares pre installed like Skupper cli, oc cli etc but you will have to install them in your local.

| Host | SSH command | Password |
| ---- | ----------- | -------- |
| Base Bastion | TBD | TBD |
| Tier 1 Bastion | TBD | TBD |
| Tier 2 Bastion | TBD | TBD |
| Tier 3 Bastion | TBD | TBD |

### OpenShift Console Connection Details
| Cluster | Console URL | Username | Password |
| ------- | ----------- | -------- | -------- |
| Base On-Premises | TBD | *your team name* | TBD |
| AWS Melbourne | TBD | *your team name* | TBD |
| AWS Sydney | TBD | *your team name* | TBD |
| AWS Singapore | TBD | *your team name* | TBD |


## Installing the Command Line Tools
If you are not using the Bastion hosts you will need to install the correct versions of the cli tools. These can be found here:

| Component                               | Download Link                                    |
|-------------------------------------|-------------------------------------------------------|
| Install Skupper cli                  | [Download here](https://skupper.io/install/index.html) |
| openshift cli                       | [Download here](https://skupper.io/install/index.html) |
| git cli                             | [Download here](https://git-scm.com/downloads)


## Getting Set Up to Start the Hackathon

Online boutique application is already installed into a single namespace in the ``Base`` On Premises Cluster provided above. To view and get a feel of the application.

#### Log on to the Base Bastion Server

```TBC```

```ssh lab-user@<insert url>```

```
bash
oc project teamname-onprem

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

1. Access the web frontend in a browser using the frontend's `Route`.  

```bash
oc get route frontend -o jsonpath='{.spec.host}'
```

### Deploy Online Boutique - FOR REFERENCE ONLY

To get set for the hackathon you should start by deploying the entire application into a single namespace on the ``Tier 1`` cluster.

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

