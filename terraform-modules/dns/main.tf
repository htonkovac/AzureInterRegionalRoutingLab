
locals {
  private_dns_zones = {
    azure-automation-net              = "privatelink.azure-automation.net"
    database-windows-net              = "privatelink.database.windows.net"
    privatelink-sql-azuresynapse-net  = "privatelink.sql.azuresynapse.net"
    privatelink-dev-azuresynapse-net  = "privatelink.dev.azuresynapse.net"
    privatelink-blob-core-windows-net = "privatelink.blob.core.windows.net"
    privatelink-vaultcore-azure-net   = "privatelink.vaultcore.azure.net"
  }
}

resource "azurerm_private_dns_zone" "private_dns_zones" {
  for_each = local.private_dns_zones

  name                = each.value
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_network_links" {
  for_each = { for sp in setproduct(toset(values(local.private_dns_zones)), toset(var.vnet_ids)) : "${sp[0]}.${sp[1]}" => sp }

  name                  = "${split("/", each.value[1])[2]}-${split("/", each.value[1])[8]}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value[0]
  virtual_network_id    = each.value[1]

  depends_on = [
    azurerm_private_dns_zone.private_dns_zones
  ]
}
