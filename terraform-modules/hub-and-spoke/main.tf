module "hub" {
  source              = "./modules/vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_name           = var.hub_vnet_name
  address_space       = var.hub_address_space
  subnets             = var.hub_subnets
}

module "spokes" {
  source   = "./modules/vnet"
  for_each = var.spokes

  resource_group_name = var.resource_group_name
  location            = var.location

  vnet_name     = each.value.vnet_name
  address_space = each.value.address_space
  subnets       = each.value.subnets
}

module "spoke_routes" {
  source = "./modules/spoke-routes"
  for_each = var.spokes

  other_spokes = {for k,spoke in var.spokes: k=>spoke if k != each.key}
  vnet_name     = each.value.vnet_name
  address_space = each.value.address_space

  firewall_ip = "1.1.1.1"
}
