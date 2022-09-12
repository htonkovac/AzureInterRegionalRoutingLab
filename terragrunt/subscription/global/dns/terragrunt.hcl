terraform {
  source = "${get_repo_root()}/terraform-modules/dns"
}

include {
  path = find_in_parent_folders()
}

dependency "net_ew1" {
  config_path = "../../eu-west-1/hub-and-spoke"

  mock_outputs_allowed_terraform_commands = ["plan", "validate", "destroy"]
  mock_outputs = {
    hub = {
      vnet_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/virtualNetworks/<virtual-network-name>"
    }
  }
}

dependency "net_ue2" {
  config_path = "../../us-east-2/hub-and-spoke"

  mock_outputs_allowed_terraform_commands = ["plan", "validate", "destroy"]
  mock_outputs = {
    hub = {
      vnet_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/virtualNetworks/<virtual-network-name>"
    }
  }
}

inputs = {
  vnet_ids = [
    dependency.net_ue2.outputs.hub.vnet_id,
    dependency.net_ew1.outputs.hub.vnet_id,
  ]
  private_dns_zones = {
    "azure-lab" = "azure.lab"
  }
}
