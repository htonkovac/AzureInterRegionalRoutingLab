terraform {
  source = "${get_repo_root()}/terraform-modules/la-wkspc"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  name = "la-wkspc"
  tags = {}
}