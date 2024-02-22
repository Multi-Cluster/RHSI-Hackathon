# Red Hat Service Interconnect - February APAC Hackathon

## Background

Acme's Bargain Barn is an online retail store based in Singapore. Their website deployment architecture requires restructuring so they can continue to scale, improve securitry, and move workloads to cloud.

The online retail store is a traditional 3-tier architecture, however all three tiers have been deployed into a single on-premises OpenShift namespace. For technical reasons not important to this activity, Acme have landed on a deployment architecture that will place each tier in different regions.

Your team's task is to take the existing fully-functional store and move each tier to the correct region - WITH ZERO SERVICE INTERRUPTION.

Luckily Acme have just procured Red Hat Service Interconnect - an application-networking solution that among facilitates moving application components around with zero code changes.

## Activity 

You are in a race to capture the flag!!! The first team to migrate their application using two different methods will be the winner of an increadibly average prize... (Sorry - budgets are tight.)

You will be broken into cross-functional teams where you will use your collective skills to work out how to use Service Interconnect to progressively migrate the application whilst not impacting the service. To do this you will need to read up on Service Interconnect's features and commands. But don't worry - we will give you links to the most important commands.

The key Service Interconnect concepts you will need to understand to get to the finish line are:
* Sites
* Links
* Services and Service Endpoints
* Service Synchronisation

Scenario 1 will require you to migrate the application and let Service Interconnect work out where to publish the service.  
Scenario 2 will require you to migrate the application and then selectively expose which services are exposed in which application tier.

### Don't Panic
If you get stuck and want to wave the white flag - then we have a set of "break glass" instructions that will walk you through each solution.

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

### Accessing the Clusters

Each cluster has a bastion host that you can use to work directly with the cluster. By SSHing to the Bastion you have pre-configured access to your OpenShift cluster, and the ``oc`` and ``skupper`` cli tools are already installed.

Using the Bastion hosts is completely optional, you can use your own terminal if you choose. This will mean that you need to the install ``skupper`` and ``oc`` cli tools on your laptop.

```mermaid  %%{init: {"flowchart": {"htmlLabels": false}} }%%
  flowchart

      A[["On-Prem cluster 
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


      E[["RHEL On-Prem Bastion 
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

## Accessing the Environments

Before you start you will need your facilitator to provide the user ids and passwords for each system in the environment.

You can either use the bastion provided above or use your local machine for the hackathon. Bastion will have all the required softwares pre installed like Skupper cli, oc cli etc but you will have to install them in your local.

### Bastion Host Connection Details

| Host | SSH command | Password |
| ---- | ----------- | -------- |
| On-Prem Bastion | TBD | TBD |
| Tier 1 Bastion | TBD | TBD |
| Tier 2 Bastion | TBD | TBD |
| Tier 3 Bastion | TBD | TBD |

### OpenShift Console Connection Details
| Cluster | Console URL | Username | Password |
| ------- | ----------- | -------- | -------- |
| On-Prem On-Premises | TBD | *your team name* | TBD |
| AWS Melbourne | TBD | *your team name* | TBD |
| AWS Sydney | TBD | *your team name* | TBD |
| AWS Singapore | TBD | *your team name* | TBD |


## Getting Set Up to Start the Hackathon

## Installing the Command Line Tools (Optional)
**If you are not using the Bastion hosts** you will need to install the correct versions of the cli tools. These can be found here:

| Component                               | Download Link                                    |
|-------------------------------------|-------------------------------------------------------|
| Install Skupper cli                  | [Download here](https://skupper.io/install/index.html) |
| openshift cli                       | [Download here](https://skupper.io/install/index.html) |
| git cli                             | [Download here](https://git-scm.com/downloads)

## Git Repository Structure
The challenge will use a git repo that contains all of the deployment artifacts that you will need. You will need to clone the repository into each bastion host. 

The ``./online-boutique/OpenShift`` directory is where you will do all your work out of. 

***You will not need to edit any of the files in order to accomplish the tasks.*** Just apply each yaml file to deploy each component.

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

## Existing Boutique Store Walkthrough
Online boutique application is already installed into a single namespace in the ``On-Prem`` On Premises Cluster provided above. To view and get a feel of the application.

### Log on to the On-Prem Bastion Server

Use the connectivity details described above to SSH to the On-Prem bastion server. E.g.:

```ssh blue-team@on-prem.bastion.host.com```

Connect to your team's project

```
bash
oc project blue-team-onprem

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
Paste the route into your browser. **Note:** The url needs to be ``http``, not ``https``.
