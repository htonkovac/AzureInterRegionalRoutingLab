resource "azurerm_route" "spoke_route" {
  for_each = var.other_spokes

  name                   = "${var.vnet_name}-default-route-${each.value.name}"
  resource_group_name    = var.resource_group_name
  route_table_name       = var.route_table_name
  address_prefix         = each.value.address_space
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_ip
}
