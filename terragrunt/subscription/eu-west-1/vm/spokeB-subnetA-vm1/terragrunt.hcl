terraform {
  source = "${get_repo_root()}/terraform-modules/ubuntu-ngnix-vm"
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
      spokeB = {
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
  name                     = "${local.location_hyphenated}-ba1"
  subnet_id                = dependency.net.outputs.spokes["spokeB"].subnets["SubnetA"].id
  ssh_public_key_file_path = "${get_repo_root()}/ssh-keys/mykey.pub"
}
