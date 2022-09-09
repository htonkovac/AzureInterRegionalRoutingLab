resource "azurerm_route" "spoke_route" {
  for_each = var.other_spokes

  name                   = "default-route-${each.value.vnet_name}"
  resource_group_name    = var.resource_group_name
  route_table_name       = var.route_table_name
  address_prefix         = each.value.address_space[0] #TODO: this won't support multiple address spaces per vnet
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_ip
}

resource "azurerm_route" "to_home_hub" {
  name                   = "default-route-to-hub"
  resource_group_name    = var.resource_group_name
  route_table_name       = var.route_table_name
  address_prefix         = var.hub_address_space[0] #TODO: this won't support multiple address spaces per vnet
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_ip
}
