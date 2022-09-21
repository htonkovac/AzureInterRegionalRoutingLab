resource "azurerm_firewall_policy_rule_collection_group" "all_internal" {
  name               = "network_rule_allow_all_internal"
  firewall_policy_id = var.firewall_policy_id
  priority           = 31000

  network_rule_collection {
    name     = "network_rule_allow_all_internal"
    priority = 4100
    action   = "Allow"
    rule {
      name                  = "network_rule_allow_all_internal"
      protocols             = ["*"]
      source_addresses      = ["10.0.0.0/8"]
      destination_addresses = ["10.0.0.0/8"]
      destination_ports     = ["*"]
    }
  }

}
