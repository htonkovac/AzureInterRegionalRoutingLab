resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
}

resource "azurerm_virtual_network_dns_servers" "vnet" {
  virtual_network_id = azurerm_virtual_network.vnet.id
  dns_servers        = var.dns_servers
}

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                                           = each.value.name
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = each.value.address_space
  service_endpoints                              = try(each.value.service_endpoints, null)
  enforce_private_link_endpoint_network_policies = try(each.value.enforce_private_link_endpoint_network_policies, false)
  enforce_private_link_service_network_policies  = try(each.value.enforce_private_link_service_network_policies, false)

  dynamic "delegation" {
    for_each = try(each.value.service_endpoints.delegations, {})
    content {
      name = delegation.key
      service_delegation {
        name    = delegation.value.service_name
        actions = try(delegation.value.service_actions, [])
      }
    }
  }
}
