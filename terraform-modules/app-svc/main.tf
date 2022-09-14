resource "azurerm_app_service_plan" "x" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "x" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  app_service_plan_id = azurerm_app_service_plan.x.id

site_config {
    default_documents = ["hostingstart.html"]
}

  auth_settings {
    enabled = false
  }
}

resource "azurerm_private_endpoint" "x" {
  name                = "${var.name}-pe"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.pe_subnet_id
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
  private_service_connection {
    is_manual_connection           = false
    private_connection_resource_id = azurerm_app_service.x.id
    name                           = "${var.name}-psc"
    subresource_names              = ["sites"]
  }
}
