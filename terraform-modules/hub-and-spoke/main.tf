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
  source   = "./modules/spoke-routes"
  for_each = var.spokes

  resource_group_name = var.resource_group_name
/* TODO: expose as var */
  /* other_spokes     = { for k, spoke in var.spokes : k => spoke if k != each.key } */
  other_spokes     = var.spokes
  vnet_name        = each.value.vnet_name
  route_table_name = module.spokes[each.key].default_route_table_name
  address_space    = each.value.address_space

  hub_address_space = var.hub_address_space
  firewall_ip = module.az_fw.private_ip_address
}
