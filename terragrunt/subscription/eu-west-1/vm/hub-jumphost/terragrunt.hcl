terraform {
  source = "${get_repo_root()}/terraform-modules/ubuntu-ngnix-vm"
}

include {
  path = find_in_parent_folders()
}

locals {
  location_hyphenated = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.location_hyphenated
}

dependencies {
  paths = ["../../../global/dns"]
}

dependency "net" {
  config_path = "../../hub-and-spoke"

  mock_outputs = {
    hub = {
      subnets = {
        "JumpHostSubnet" = {
          id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/virtualNetworks/<virtual-network-name>/subnets/<subnet-name>"
        }
      }
    }
  }
}

inputs = {
  name                     = "${local.location_hyphenated}-jumphost"
  subnet_id                = dependency.net.outputs.hub.subnets["JumpHostSubnet"].id
  ssh_public_key_file_path = "${get_repo_root()}/ssh-keys/mykey.pub"
}
