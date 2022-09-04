terraform {
  source = "${get_repo_root()}/terraform-modules/hub-and-spoke"
}

locals {
  location_hyphenated = join("-", split(" ", lower(read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.location)))
}
include {
  path = find_in_parent_folders()
}

inputs = {
  hub_vnet_name     = "hub-vnet-${local.location_hyphenated}"
  hub_address_space = ["10.0.0.0/16"]
  hub_subnets = {
    "AzureBastionSubnet" = {
      name          = "AzureBastionSubnet",
      address_space = ["10.0.1.0/24"]
    },
    "GatewaySubnet" = {
      name          = "GatewaySubnet",
      address_space = ["10.0.2.0/24"]
    },
    "AzureFirewallSubnet" = {
      name          = "AzureFirewallSubnet",
      address_space = ["10.0.3.0/24"]
    },
    "AzureFirewallManagementSubnet" = {
      name          = "AzureFirewallManagementSubnet",
      address_space = ["10.0.5.0/24"]
      no_rt         = true
    },
    "ApplicationGatewaySubnet" = {
      name          = "ApplicationGatewaySubnet",
      address_space = ["10.0.6.0/24"]
    },
    "TestingSubnet" = {
      name          = "TestingSubnet",
      address_space = ["10.0.7.0/24"]
    }
  }
  spokes = {
    spokeA = {
      vnet_name     = "spoke-A-${local.location_hyphenated}"
      address_space = ["10.1.0.0/16"]
      subnets = {
        "SpokeASubnetA" = {
          name          = "SpokeASubnetA",
          address_space = ["10.1.1.0/24"]
        },
        "SpokeASubnetB" = {
          name          = "SpokeASubnetB",
          address_space = ["10.1.2.0/24"]
        },
        "SpokeASubnetC" = {
          name          = "SpokeASubnnetC",
          address_space = ["10.1.3.0/24"]
        },
      }
    },
    spokeB = {
      vnet_name     = "spoke-B-${local.location_hyphenated}"
      address_space = ["10.2.0.0/16"]
      subnets = {
        "SpokeBSubnetA" = {
          name          = "SpokeASubnetA",
          address_space = ["10.2.1.0/24"]
        }
    } },
    spokePE = {
      vnet_name     = "spoke-PE-${local.location_hyphenated}"
      address_space = ["10.3.0.0/16"]
      subnets       = {}
    }
  }
}