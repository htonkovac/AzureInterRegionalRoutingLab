variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}

variable "hub_vnet_name" {
  type = string
}

variable "hub_address_space" {
  type = list(string)
}

variable "hub_subnets" {
  description = "waiting for tf 1.3 :)"
  type        = any
}

variable "spokes" {
  description = "waiting for tf 1.3 :)"
  type        = any
}

variable "firewall_name" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}
