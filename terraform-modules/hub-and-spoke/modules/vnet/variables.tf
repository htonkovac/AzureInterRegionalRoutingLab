variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "subnets" {
  description = "waiting for tf 1.3 :)"
  type        = any
}

variable "dns_servers" {
  type = list(string)
}