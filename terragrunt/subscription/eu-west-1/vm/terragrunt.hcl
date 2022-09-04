terraform {
  source = "${get_repo_root()}/terraform-modules/ubuntu-ngnix-vm"
}

include {
  path = find_in_parent_folders()
}

locals {
  location_hyphenated = join("-", split(" ", lower(read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.location)))
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

inputs = {
  name      = "vm1-${local.location_hyphenated}"
  subnet_id = dependency.net.outputs.spokes["spokeA"].subnets["SpokeASubnetA"].id
}
