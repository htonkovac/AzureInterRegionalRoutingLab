output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "subnets" {
  value = azurerm_subnet.subnets
}

output "default_route_table_name" {
  value = azurerm_route_table.rt.name
}