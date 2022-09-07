resource "azurerm_subnet_route_table_association" "vnet" {
  for_each = { for k, subnet in var.subnets : k => subnet if try(subnet.no_rt, false) == false }

  subnet_id      = azurerm_subnet.subnets[each.key].id
  route_table_id = try(each.value.route_table_id, azurerm_route_table.rt.id)
}

resource "azurerm_route_table" "rt" {
  name                          = "${var.vnet_name}-default-rt"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  disable_bgp_route_propagation = false
}

resource "azurerm_route" "default_routes" {
  for_each = var.other_spokes

  name                   = "${var.vnet_name}-default-route-${each.value.name}"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.rt.name
  address_prefix         = each.value.address_space
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_ip
}
