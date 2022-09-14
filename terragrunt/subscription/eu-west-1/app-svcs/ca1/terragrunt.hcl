terraform {
  source = "${get_repo_root()}/terraform-modules/app-svc"
}

include {
  path = find_in_parent_folders()
}

locals {
  location_hyphenated = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.location_hyphenated
}

dependency "net" {
  config_path = "../../hub-and-spoke"

  mock_outputs = {
    spokes = {
      spokeA = {
        subnets = {
          "SubnetA" = {
            id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/virtualNetworks/<virtual-network-name>/subnets/<subnet-name>"
          }
        }
      }
    }
  }
}

dependency "dns" {
  config_path = "../../../global/dns"

  mock_outputs_allowed_terraform_commands = ["plan", "validate", "destroy"]
  mock_outputs = {
    dns_zones = {
      privatelink-vaultcore-azure-net = {
        id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/privateDnsZones/<zone-name>"
      }
    }
  }
}

inputs = {
  name                = "${local.location_hyphenated}-ca1"
  pe_subnet_id        = dependency.net.outputs.spokes["spokeB"].subnets["SubnetA"].id
  private_dns_zone_id = dependency.dns.outputs.dns_zones["privatelink-azurewebsites-net"].id
}
