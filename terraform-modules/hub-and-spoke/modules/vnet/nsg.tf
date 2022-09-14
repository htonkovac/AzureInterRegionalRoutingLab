resource "azurerm_subnet_network_security_group_association" "vnet" {
  # subnets which don't have no_nsg specified and no custom nsg
  for_each = { for k, subnet in var.subnets : k => subnet if try(subnet.no_nsg, false) == false && try(subnet.nsg.name, "") == "" }

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.vnet_name}-default-nsg"
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_subnet_network_security_group_association" "subnet_specific" {
  # subnets which don't have no_nsg specified but have a custom nsg
  for_each = { for k, subnet in var.subnets : k => subnet if try(subnet.no_nsg, false) == false && try(subnet.nsg.name, "") != "" }

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg_subnet_specific[each.key].id
}


resource "azurerm_network_security_group" "nsg_subnet_specific" {
  for_each = { for k, subnet in var.subnets : k => subnet.nsg if try(subnet.no_nsg, false) == false && try(subnet.nsg.name, "") != "" }
  #TODO: rules are missing
  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
}
/* TODO https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule
resource "azurerm_network_security_rule" "subnet_specific" {
  name                        = "test123"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.example.name
} */