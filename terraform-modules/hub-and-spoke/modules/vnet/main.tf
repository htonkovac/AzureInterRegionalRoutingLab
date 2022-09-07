resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
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

resource "azurerm_subnet_network_security_group_association" "vnet" {
  for_each = { for k, subnet in var.subnets : k => subnet if try(subnet.no_nsg, false) == false }

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.vnet_name}-default-nsg"
  resource_group_name = var.resource_group_name
  location            = var.location
}
