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
# Sources
I would like to dearly thank all sources.
1. https://gaunacode.com/using-terragrunt-to-deploy-to-azure
2. https://faizanbashir.me/building-an-nginx-webserver-on-azure-using-terraform

