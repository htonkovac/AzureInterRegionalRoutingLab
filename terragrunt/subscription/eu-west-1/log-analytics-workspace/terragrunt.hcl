terraform {
  source = "${get_repo_root()}/terraform-modules/la-wkspc"
}

include {
  path = find_in_parent_folders()
}

locals {
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  location = local.region_vars.locals.location
}

inputs = {
  name           = "la-wkspc"
  /* location            = local.location */ #I think it's useless

  tags = {}
}