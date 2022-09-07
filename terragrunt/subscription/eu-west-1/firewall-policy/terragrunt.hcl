terraform {
  source = "${get_repo_root()}/terraform-modules/az-fw"
}

include {
  path = find_in_parent_folders()
}

locals {
  location_hyphenated = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.location_hyphenated
}

inputs = {
  firewall_policy_name = "azfw-${local.location_hyphenated}"
}
