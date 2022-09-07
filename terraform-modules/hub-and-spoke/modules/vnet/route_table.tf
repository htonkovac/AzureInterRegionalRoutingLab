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
