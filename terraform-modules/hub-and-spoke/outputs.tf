output "hub" {
  value = module.hub
}

output "spokes" {
  value = module.spokes
}

output "fw_public_ip_address" {
  value = module.az_fw.public_ip_address
}
