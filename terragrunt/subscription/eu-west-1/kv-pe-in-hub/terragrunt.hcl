terraform {
  source = "${get_repo_root()}/terraform-modules/hub-and-spoke"
}

locals {
  location_hyphenated = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.location_hyphenated
}

include {
  path = find_in_parent_folders()
}

dependency "net" {
  config_path = "../hub-and-spoke"

  mock_outputs = {
    spokes = {
      spokeA = {
        subnets = {
          "SpokeASubnetA" = {
            id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/virtualNetworks/<virtual-network-name>/subnets/<subnet-name>"
          }
        }
      }
    }
  }
}

dependency "dns" {
  config_path = "../../global/hub-and-spoke"

  mock_outputs = {
    dns_zones = {
      privatelink-vaultcore-azure-net = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/virtualNetworks/<virtual-network-name>/subnets/<subnet-name>"
    }
  }

}
inputs = {
  name      = "mykvlskdjfoiejfs"
  subnet_id = dependency.net.outputs.hub.subnets["TestingSubnet"].id

  private_dns_zone_id = dependency.dns.outputs.dns_zones["privatelink-vaultcore-azure-net"].id
}
