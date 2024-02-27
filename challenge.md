
## Scenario 1 

Task Requirements:

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
| Install Service Interconnect        | [Documentation](https://skupper.io/install/index.html) |
| Deploying Service Interconnect      | |
| Linking sites | [Documentation](https://skupper.io/docs/cli/tokens.html) 
plus a link for skupper link create) |
| Using the console | |
| Exposing Services | |
| Working with Tokens                 |   |
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
| Disabling service sync              | [Documentation](https://skupper.io/docs/cli/tokens.html)  |
| Consuming exposed services          | review "skupper init -h" options and search for service-sync |


## Scenario 3 (BONUS)

DO NOT DELETE what you've created in Scenario 2. This is an extension of that scenario's end product.

Requirements:

1. Update your Route 53 hosted zone with a CNAME record to point to the Frontend route
