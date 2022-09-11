variable "resource_group_name" {
  type = string
}

variable "vnet_ids" {
  type = list(string)
}

variable "private_dns_zones" {
  type = map(string)
}
