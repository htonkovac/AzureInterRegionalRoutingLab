module "az_fw" {
  source = "./modules/az-fw"

  resource_group_name = var.resource_group_name
  location            = var.location

  firewall_name                 = var.firewall_name
  firewall_subnet_id            = module.hub.subnets["AzureFirewallSubnet"].id
  firewall_management_subnet_id = module.hub.subnets["AzureFirewallManagementSubnet"].id

  firewall_policy_id  = var.firewall_policy_id
  log_analytics_workspace_id    = var.log_analytics_workspace_id
}
