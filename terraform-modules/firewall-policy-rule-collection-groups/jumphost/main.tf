resource "azurerm_firewall_policy_rule_collection_group" "jumphost" {
  name               = "jumphost"
  firewall_policy_id = var.firewall_policy_id
  priority           = 30000

  nat_rule_collection {
    name     = "jumphost_nat"
    priority = 3000
    action   = "Dnat"
    rule {
      name                = "nat_jumphost"
      protocols           = ["TCP"]
      source_addresses    = ["*"]
      destination_address = var.firewall_public_ip
      destination_ports   = ["22"]
      translated_address  = var.jump_host_ip
      translated_port     = "22"
    }
  }

  network_rule_collection {
    name     = "ssh_in_private_range"
    priority = 4000
    action   = "Allow"
    rule {
      name                  = "ssh_in_private_range"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.0.0/8"]
      destination_addresses = ["10.0.0.0/8"]
      destination_ports     = ["22"]
    }
  }

}
