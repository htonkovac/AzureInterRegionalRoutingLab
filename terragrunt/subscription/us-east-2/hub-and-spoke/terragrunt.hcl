terraform {
  source = "${get_repo_root()}/terraform-modules/hub-and-spoke"
}

locals {
  location_hyphenated = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.location_hyphenated
}
include {
  path = find_in_parent_folders()
}

dependency "laws" {
  config_path = "../../eu-west-1/log-analytics-workspace"

  mock_outputs = {
    id = "/subscriptions/xxx/resourceGroups/xx/providers/Microsoft.OperationalInsights/workspaces/la-wkspc"
  }
}

dependency "firewall_policy" {
  config_path = "../firewall-policy"

  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
  mock_outputs = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mygroup1/providers/Microsoft.Network/firewallPolicies/policy1"
  }
}


inputs = {
  hub_vnet_name     = "${local.location_hyphenated}-hub"
  hub_address_space = ["10.10.0.0/16"]
  hub_subnets = {
    "JumpHostSubnet" = {
      name          = "JumpHostSubnet",
      address_space = ["10.10.1.0/24"]
    },
    "GatewaySubnet" = {
      name          = "GatewaySubnet",
      address_space = ["10.10.2.0/24"],
      no_nsg        = true
      no_rt         = true
    },
    "AzureFirewallSubnet" = {
      name          = "AzureFirewallSubnet",
      address_space = ["10.10.3.0/24"]
      no_nsg        = true
      no_rt         = true
    },
    "AzureFirewallManagementSubnet" = {
      name          = "AzureFirewallManagementSubnet",
      address_space = ["10.10.5.0/24"]
      no_rt         = true
      no_nsg        = true
    },
    "ApplicationGatewaySubnet" = {
      name          = "ApplicationGatewaySubnet",
      address_space = ["10.10.6.0/24"]
    },
    "TestingSubnet" = {
      name          = "TestingSubnet",
      address_space = ["10.10.7.0/24"]
    }
  }
  firewall_name              = "azfw-${local.location_hyphenated}"
  log_analytics_workspace_id = dependency.laws.outputs.id
  firewall_policy_id         = dependency.firewall_policy.outputs.id

  spokes = {
    spokeA = {
      vnet_name     = "${local.location_hyphenated}-spoke-A"
      address_space = ["10.11.0.0/16"]
      subnets = {
        "SubnetA" = {
          name                                           = "SubnetA",
          address_space                                  = ["10.11.1.0/24"],
          enforce_private_link_endpoint_network_policies = true
        },
        "SubnetB" = {
          name                                           = "SubnetB",
          address_space                                  = ["10.11.2.0/24"],
          enforce_private_link_endpoint_network_policies = false
        },
        "SubnetC" = {
          name          = "SubnetC",
          address_space = ["10.11.3.0/24"]
        },
      }
    },
    spokeB = {
      vnet_name     = "${local.location_hyphenated}-spoke-B"
      address_space = ["10.12.0.0/16"]
      subnets = {
        "SubnetA" = {
          name          = "SubnetA",
          address_space = ["10.12.1.0/24"]
        },
        "SubnetB" = {
          name                                           = "SubnetB",
          address_space                                  = ["10.12.2.0/24"],
          enforce_private_link_endpoint_network_policies = false
        },
        "SubnetC" = {
          name          = "SubnetC",
          address_space = ["10.12.3.0/24"]
        },
      }
    },
    spokeC = {
      vnet_name     = "${local.location_hyphenated}-spoke-C"
      address_space = ["10.13.0.0/16"]
      subnets = {
        "SubnetA" = {
          name          = "SubnetA",
          address_space = ["10.13.1.0/24"]
        },
        "SubnetB" = {
          name                                           = "SubnetB",
          address_space                                  = ["10.13.2.0/24"],
          enforce_private_link_endpoint_network_policies = false
        },
        "SubnetC" = {
          name          = "SubnetC",
          address_space = ["10.13.3.0/24"]
        },
      }
    }
  }
}
