resource "azurerm_firewall" "fw" {
  name                = var.firewall_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "AZFW_VNet"
  sku_tier            = "Premium"
  firewall_policy_id  = var.firewall_policy_id

  ip_configuration {
    name                 = "ip_configuration"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.fw.id
  }

  management_ip_configuration {
    name                 = "management_ip_configuration"
    subnet_id            = var.firewall_management_subnet_id
    public_ip_address_id = azurerm_public_ip.fw_mgmt.id
  }
}

resource "azurerm_public_ip" "fw" {
  name                = "${var.firewall_name}-fw-ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "fw_mgmt" {
  name                = "${var.firewall_name}-fw-mgmt-ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

data "azurerm_monitor_diagnostic_categories" "categories" {
  resource_id = azurerm_firewall.fw.id
}

resource "azurerm_monitor_diagnostic_setting" "settings" {
  name                       = "diag_settings"
  target_resource_id         = azurerm_firewall.fw.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  log_analytics_destination_type = "AzureDiagnostics"
  
  dynamic "log" {
    for_each = data.azurerm_monitor_diagnostic_categories.categories.logs
    content {
      category = log.value
      enabled  = true

      retention_policy {
        enabled = false
      }
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.categories.metrics
    content {
      category = metric.value
      enabled  = true

      retention_policy {
        enabled = false
      }
    }
  }
}
