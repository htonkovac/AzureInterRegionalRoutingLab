resource "azurerm_firewall_policy" "policy" {
  name                = var.firewall_policy_name
  resource_group_name = var.resource_group_name
  location            = var.location

  dns {
    proxy_enabled = true
  }
}