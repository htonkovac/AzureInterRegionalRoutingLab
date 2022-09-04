# AzureInterRegionalRoutingLab
The goal of this repo is to showcase a couple of InterRegion routing usecases. Determining the right route table entries can be tricky at times, hence why the lab was created.

![Excalidraw](docs/diagrams/AzureInterRegionalRoutingLab.png)



# Terragrunt
## applying whole region
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


# Sources
1. https://gaunacode.com/using-terragrunt-to-deploy-to-azure#comments-list

