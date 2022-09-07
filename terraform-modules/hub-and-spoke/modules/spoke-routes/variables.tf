variable "resource_group_name" {
  type = string
}

variable "route_table_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "firewall_ip" {
  type = string
}

variable "other_spokes" {
  type = map(object({
    name : string,
    address_space : string
  }))
  default = {}
}