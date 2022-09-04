module "hub" {
  source              = "./modules/vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_name           = var.hub_vnet_name
  address_space       = var.hub_address_space
  subnets             = var.hub_subnets
}

module "spokes" {
  source   = "./modules/vnet"
  for_each = var.spokes

  resource_group_name = var.resource_group_name
  location            = var.location

  vnet_name     = each.value.vnet_name
  address_space = each.value.address_space
  subnets       = each.value.subnets
}

resource "azurerm_virtual_network_peering" "hub-to-spoke" {
  for_each = var.spokes

  name                      = "hub-to-${module.spokes[each.key].vnet_name}"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = module.hub.vnet_name
  remote_virtual_network_id = module.spokes[each.key].vnet_id
}

resource "azurerm_virtual_network_peering" "spoke-to-hub" {
  for_each = var.spokes

  name                      = "spoke-to-hub"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = module.spokes[each.key].vnet_name
  remote_virtual_network_id = module.hub.vnet_id
}

