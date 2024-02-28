
## Scenario 1 

Task Requirements:

1. Zero service disruption throughout the migration (outages will be monitored for)
2. Naming of namespaces follows the convention of prefixing team names to all created namespaces, with tier-specific designations (e.g., Teamname-tier1-s1 for Tier1 Cluster etc.)
3. No changes to the application code and/or K8s manifests
4. Deploy to three clusters where ALL services are visible to each other (**HINT:** cast your eyes to the `service-sync-enabled` flag as part of the `skupper` CLI)
5. Maintain the `frontend` route should still remain in the on-prem namespace

The objective is to progressively migrate microservices to different cloud VPCs while maintaining functionality. 


```mermaid  %%{init: {"flowchart": {"htmlLabels": false}} }%%
  flowchart LR

      z([User])

      A[["On-Prem cluster  
      (Singapore)
        ------------------- 
        no pods running but
        all service definitions available here"]]

      B[["Tier1 cluster 
      (AWS Melbourne)
        -------------------
        Frontend microservices pod, service and
        all service definitions visible here"]]

      C[["Tier2 cluster  
      (AWS Sydney)
        -------------------
        middleware microservices pods, services and
        all service definitions visible here"]]

      D[["Tier3 cluster  
      {AWS Singapore)}
        -------------------
        Payments microservices pods, services and
        all service definitions visible here"]]

    z --> A --> B --> C --> D    
  ```

## Documentation

The following documentation matrix will lead you to important information to achieve the Hackathon's end goal. Running `skupper --help` will also give you plenty of direction. 

| Topic                               | Documentation Link                                    |
|-------------------------------------|-------------------------------------------------------| 
| Resources                           | [Resources]([https://access.redhat.com/documentation/en-us/red_hat_application_interconnect/](https://access.redhat.com/documentation/en-us/red_hat_service_interconnect/1.4/html/getting_started/resources)
| Install Service Interconnect        | [Documentation](https://skupper.io/install/index.html) |
| Creating a site      | https://skupper.io/docs/cli/index.html#creating-using-cli |
| Linking sites | https://skupper.io/docs/cli/index.html#linking-sites  |
| Using the console | https://skupper.io/docs/console/index.html |
| Exposing Services | https://skupper.io/docs/cli/index.html#exposing-services-ns |
| Working with Tokens                 | https://skupper.io/docs/cli/index.html#linking-sites |
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


```mermaid  %%{init: {"flowchart": {"htmlLabels": false}} }%%
  flowchart LR

      z([User])

      A[["On-Prem cluster  
      (Singapore)
        ------------------- 
        no pods running but
        Only frontend service definition available here"]]

      B[["Tier1 cluster 
      (AWS Melbourne)
        -------------------
        Frontend microservices pod, service and
        Only tier2 service definitions visible here"]]

      C[["Tier2 cluster  
      (AWS Sydney)
        -------------------
        middleware microservices pods, services and
        Only tier3 service definitions visible here"]]

      D[["Tier3 cluster  
      {AWS Singapore)}
        -------------------
        Payments microservices pods "]]

    z --> A --> B --> C --> D    
  ```
## Documentation

| Topic                               | Documentation Link                                    |
|-------------------------------------|-------------------------------------------------------|
| Disabling service sync              | [Documentation](https://skupper.io/docs/cli/tokens.html)  |
| Consuming exposed services          | review "skupper init -h" options and search for service-sync |


## Scenario 3 (BONUS)

DO NOT DELETE what you've created in Scenario 2. This is an extension of that scenario's end product.

Requirements:

1. Update your Route 53 hosted zone with a CNAME record to point to the Frontend route
2. Decommission RHSI on Onprem cluster.

**Before**

```mermaid  %%{init: {"flowchart": {"htmlLabels": false}} }%%
  flowchart LR

      z([User])

      A[["On-Prem cluster  
      (Singapore)
        -------------------
        Full Single-Namespace Application "]]

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

    z --> A --> B --> C --> D    
  ```


**After**

```mermaid  %%{init: {"flowchart": {"htmlLabels": false}} }%%
  flowchart LR
      z([User])

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

    z --> B --> C --> D    
  ```

## Verification:

A load generator service has been deployed to continuously send request to web portal of each team. This will currently be running with a 100% success rate and should continue to be the same at the end of the migration too.

The number of failures will determine the team success of the challenge.
