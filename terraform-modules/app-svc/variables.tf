variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "name" {
  type = string
}


variable "private_endpoint_enabled" {
  type    = bool
  default = false
}
variable "pe_subnet_id" {
  type    = string
  default = ""
}
variable "private_dns_zone_id" {
  type    = string
  default = ""
}