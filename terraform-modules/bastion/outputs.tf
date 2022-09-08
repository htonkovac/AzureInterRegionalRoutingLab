output "bastion_name" {
    value = azurerm_bastion_host.bastion.name
}

output "resource_group" {
    value = azurerm_bastion_host.bastion.resource_group
}