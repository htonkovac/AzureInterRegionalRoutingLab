resource "azurerm_firewall_policy_rule_collection_group" "defaults" {
  name               = "defaults"
  firewall_policy_id = var.firewall_policy_id
  priority           = 500

  nat_rule_collection {
    name     = "nat_rule_collection1"
    priority = 300
    action   = "Dnat"
    rule {
      name                = "nat_jumphost"
      protocols           = ["TCP"]
      source_addresses    = ["*"]
      destination_address = ["*"]
      destination_ports   = ["22"]
      translated_address  = var.jump_host_ip
      translated_port     = "22"
    }
  }
}
