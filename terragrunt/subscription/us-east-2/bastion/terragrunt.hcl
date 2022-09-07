terraform {
  source = "${get_repo_root()}/terraform-modules/bastion"
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
    hub = {
      subnets = {
        "AzureBastionSubnet" = {
          id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/virtualNetworks/<virtual-network-name>/subnets/<subnet-name>"
        }
      }
    }
  }
}

inputs = {
  name      = "bastion-${local.location_hyphenated}"
  subnet_id = dependency.net.outputs.hub.subnets["AzureBastionSubnet"].id
}
