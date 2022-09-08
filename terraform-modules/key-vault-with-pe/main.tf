resource "azurerm_key_vault" "kv" {
  name                        = var.name
  resource_group_name         = var.resource_group_name
  location                    = var.location
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization   = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
}

resource "azurerm_private_endpoint" "kv" {
  name                = "${azurerm_key_vault.kv.name}-pe"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.subnet_id
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
  private_service_connection {
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.kv.id
    name                           = "${azurerm_key_vault.kv.name}-psc"
    subresource_names              = ["vault"]
  }
}

resource "azurerm_role_assignment" "yours_truly" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}
