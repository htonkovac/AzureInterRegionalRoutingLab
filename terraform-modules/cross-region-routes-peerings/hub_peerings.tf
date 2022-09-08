resource "azurerm_virtual_network_peering" "hub-to-spoke" {
  for_each = setproduct(var.hubs, var.hub)

  name                      = each.value.vnet_name
  resource_group_name       = var.resource_group_name
  virtual_network_name      = module.hub.vnet_name
  remote_virtual_network_id = module.spokes[each.key].vnet_id
}

resource "azurerm_virtual_network_peering" "spoke-to-hub" {
  for_each = var.hubs

  name                      = "spoke-to-hub"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = module.spokes[each.key].vnet_name
  remote_virtual_network_id = module.hub.vnet_id
}
data "azurerm_virtual_network" "example" {
  name                = "production"
  resource_group_name = "networking"
}