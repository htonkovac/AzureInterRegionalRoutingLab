output "private_key" {
  value = tls_private_key.key.private_key_openssh
  sensitive = true
}

output "vm_id" {
  value =azurerm_linux_virtual_machine.nginx.id
}