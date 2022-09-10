terraform {
  source = "${get_repo_root()}/terraform-modules/key-vault-with-pe"
}

locals {
  location_hyphenated = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.location_hyphenated
}

include {
  path = find_in_parent_folders()
}

dependency "net" {
  config_path = "../hub-and-spoke"

  mock_outputs = { #TODO: fix or no longer use mocks
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
  config_path = "../../global/dns"

  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
  mock_outputs = {
    dns_zones = {
      privatelink-vaultcore-azure-net = {
        id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/privateDnsZones/<zone-name>"
      }
    }
  }
}

inputs = {
  name                = "mykvlskdjfoiejfs"
  subnet_id           = dependency.net.outputs.spokes["spokeA"].subnets["SpokeASubnetA"].id
  private_dns_zone_id = dependency.dns.outputs.dns_zones["privatelink-vaultcore-azure-net"].id
}
