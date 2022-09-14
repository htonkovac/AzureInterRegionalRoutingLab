terraform {
  source = "${get_repo_root()}/terraform-modules/firewall-policy-rule-collection-groups/jumphost"
}

locals {
  location_hyphenated = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.location_hyphenated
}

include {
  path = find_in_parent_folders()
}

dependency "jumphost" {
  config_path                             = "../../vm/hub-jumphost"
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "destroy"]
  mock_outputs = {
    private_ip = "10.0.0.0"
  }
}

dependency "policy" {
  config_path = "../../firewall-policy"

  mock_outputs_allowed_terraform_commands = ["plan", "validate", "destroy"]
  mock_outputs = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mygroup1/providers/Microsoft.Network/firewallPolicies/policy1"
  }
}

dependency "net" {
  config_path = "../../hub-and-spoke"

  mock_outputs = {
    fw_public_ip_address = "10.0.0.0"
  }
}

inputs = {
  firewall_policy_id = dependency.policy.outputs.id
  firewall_public_ip = dependency.net.outputs.fw_public_ip_address
  jump_host_ip       = dependency.jumphost.outputs.private_ip
}
