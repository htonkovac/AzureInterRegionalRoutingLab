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
  config_path = "../hub-and-spoke"

  mock_outputs = {
    spokes = {
      spokeB = {
        subnets = {
          "SpokeBSubnetA" = {
            id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/virtualNetworks/<virtual-network-name>/subnets/<subnet-name>"
          }
        }
      }
    }
  }
}

inputs = {
  name      = "vm2-${local.location_hyphenated}-spokeB"
  subnet_id = dependency.net.outputs.spokes["spokeB"].subnets["SpokeBSubnetA"].id
}
