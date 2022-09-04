terraform {
  source = "${get_repo_root()}/terraform-modules/bastion"
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
    hub = {
      subnets = {
        "AzureBastionSubnet" = {
          id = "/some/id"
        }
      }
    }
  }
}

inputs = {
  name = "bastion-${local.location_hyphenated}"
  subnet_id = dependency.net.outputs.hub.subnets["AzureBastionSubnet"].id
}