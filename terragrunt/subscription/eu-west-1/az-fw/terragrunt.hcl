terraform {
  source = "${get_repo_root()}/terraform-modules/az-fw"
}

include {
  path = find_in_parent_folders()
}

locals {
  location_hyphenated = join("-", split(" ", lower(read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.location)))
}

dependency "laws" {
  config_path = "../log-analytics-workspace"

  mock_outputs = {
    id = "/subscriptions/id"
  }
}

dependency "net" {
  config_path = "../hub-and-spoke"

  mock_outputs = {
    hub = {
      subnets = {
        "AzureFirewallSubnet" = {
          id = "/some/id"
        }
        "AzureFirewallManagementSubnet" = {
          id = "/some/id"
        }
      }
    }
  }
}

inputs = {
  firewall_name                 = "azfw-${local.location_hyphenated}"
  firewall_subnet_id            = dependency.net.outputs.hub.subnets["AzureFirewallSubnet"].id
  firewall_management_subnet_id = dependency.net.outputs.hub.subnets["AzureFirewallManagementSubnet"].id
  log_analytics_workspace_id    = dependency.laws.outputs.id
}