variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "name" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "fqdns" {
  type = list(string)
}