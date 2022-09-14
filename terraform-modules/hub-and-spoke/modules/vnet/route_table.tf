resource "azurerm_subnet_route_table_association" "vnet" { #assign default route unless no_rt is specified or rt is specified
  for_each = { for k, subnet in var.subnets : k => subnet if try(subnet.no_rt, false) == false && try(subnet.rt.name, "") == "" }

  subnet_id      = azurerm_subnet.subnets[each.key].id
  route_table_id = try(azurerm_route_table.subnet_rt[each.key].id, azurerm_route_table.rt.id)
}

resource "azurerm_route_table" "rt" { #default RT
  name                          = "${var.vnet_name}-default-rt"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  disable_bgp_route_propagation = false
}

resource "azurerm_route_table" "subnet_rt" { #custom RT, create only if specified in the config
  for_each = { for k, subnet in var.subnets : k => subnet.rt if try(subnet.rt.name, "") != "" }

  name                          = each.value.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  disable_bgp_route_propagation = false
}

resource "azurerm_route" "route" {
  /* TODO: Implement custom route tables */
  for_each = {}

  name                   = each.value.name
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.subnet_rt[each.key].name
  address_prefix         = each.value.address_space
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
}
