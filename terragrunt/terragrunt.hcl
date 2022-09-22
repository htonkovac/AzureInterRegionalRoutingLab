# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load subscription variables
  subscription_vars = read_terragrunt_config(find_in_parent_folders("subscription.hcl"))

  # Automatically load region-level variables
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  backend_vars = read_terragrunt_config("${get_parent_terragrunt_dir()}/backend.hcl")

  location                     = local.region_vars.locals.location
  subscription_id              = local.subscription_vars.locals.subscription_id

  backend_storage_account_name = try(local.backend_vars.locals.storage_account_name, "tfstateazureroutinglab")
  backend_resource_group_name  = try(local.backend_vars.locals.resource_group_name,"AzureRoutingLab-TF-STATE")
  backend_container_name       = try(local.backend_vars.locals.container_name,"tf-state")
}

# Generate Azure providers
generate "versions" {
  path      = "versions_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_providers {
        azurerm = {
          source = "hashicorp/azurerm"
          version = "3.20.0"
        }
        azuread = {
            source = "hashicorp/azuread"
            version = "2.18.0"
        }
      }
    }
    provider "azurerm" {
        features {}
        subscription_id = "${local.subscription_id}"
    }
    provider "azuread" {
    }
EOF
}

remote_state {
  backend = "azurerm"
  config = {
    subscription_id      = "${local.subscription_id}"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
    resource_group_name =  "${local.backend_resource_group_name}"
    storage_account_name = "${local.backend_storage_account_name}"
    container_name =  "${local.backend_container_name}"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.subscription_vars.locals,
  local.region_vars.locals
)