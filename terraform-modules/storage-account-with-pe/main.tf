locals {
  name = "${random_string.random.result}${var.name}"
}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
  lower   = true
}

resource "azurerm_storage_account" "sa" {
  name                     = local.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_private_endpoint" "sa" {
  name                = "${azurerm_storage_account.sa.name}-pe"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.subnet_id
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
  private_service_connection {
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.sa.id
    name                           = "${azurerm_storage_account.sa.name}-psc"
    subresource_names              = ["blob"]
  }
}
