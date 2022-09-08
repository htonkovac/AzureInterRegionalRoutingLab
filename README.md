# AzureInterRegionalRoutingLab
The goal of this repo is to showcase a couple of InterRegion routing usecases. Determining the right route table entries can be tricky at times, hence why the lab was created.

![Excalidraw](docs/diagrams/AzureInterRegionalRoutingLab.png)

# Goals
Create a lab environment that can be used for demonstrating cross region traffic flow.

# Prerequisites
Terraform
Terragrunt
Azure Account with RG and SA

# Terragrunt
## applying whole region or subscription
This should be done only the first time around. Once the whole infra is deployed future changes are to be applied single module at a time
```
cd terragrunt/subscription/eu-west-1
terragrunt run-all apply
```
## applying single module
```
cd terragrunt/subscription/us-east-2/az-fw/terragrunt.hcl
terragrunt apply
```

## Terragrunt folder structure
```
terragrunt (root folder for TG. Contains a config file and one or more "subscriptions")
├── terragrunt.hcl (Defines providers and backends)
└── subscription (subscriptions contain a config file and one or more "regions")
    ├── subscription.hcl (subscription level vars)
    ├── eu-west-1 (regions contain individual terraform module deployments)
    │   ├── region.hcl (region level vars)
    │   ├── az-fw
    │   │   └── terragrunt.hcl (terraform deployment vars and dependencies on other deployments)
    │   └── hub-and-spoke
    │       └── terragrunt.hcl
    └── us-east-2
        ├── region.hcl
        ├── az-fw
        │   └── terragrunt.hcl
        └── hub-and-spoke
            └── terragrunt.hcl
```

# Azure
Private endpoints finallly have NSG and UDR support
https://azure.microsoft.com/en-us/updates/general-availability-of-network-security-groups-support-for-private-endpoints/
https://azure.microsoft.com/en-us/updates/general-availability-of-user-defined-routes-support-for-private-endpoints/

Unfortunatelly, terraform configuration renamed some of the api properties to make them more confusing:
https://github.com/hashicorp/terraform-provider-azurerm/issues/6334

`enforce_private_link_endpoint_network_policies` needs to be set to `false` in order for the provider to set `PrivateEndpointNetworkPolicies: Enabled`

# Important sources that teach important lessons
I would like to dearly thank all sources.
1. https://gaunacode.com/using-terragrunt-to-deploy-to-azure #terragrunt azure introduction
3. https://www.youtube.com/watch?v=LuKYu9ASGyo #terragrunt introduction
4. https://journeyofthegeek.com #many blog posts from this guy showcase many usecases in azure networking
5. https://cloudnetsec.blogspot.com/2019/02/azure-intra-region-and-inter-region.html # especially important blog post 

# Places I've stolen code snippets from:
6. https://jeffreyjblanchard.medium.com/azure-private-endpoints-and-terraform-85450fe9861c # deploying a KV
2. https://faizanbashir.me/building-an-nginx-webserver-on-azure-using-terraform #deploying a VM in azureWe
