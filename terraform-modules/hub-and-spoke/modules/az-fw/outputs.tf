output "id" {
  value = azurerm_firewall.fw.id
}

output "private_ip_address" {
  value = azurerm_firewall.fw.ip_configuration[0].private_ip_address
}

output "public_ip_address" {
  value = azurerm_public_ip.fw.ip_address
}
