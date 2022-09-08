resource "azurerm_network_interface" "nic" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "nginx" {
  size                = "Standard_B1ls"
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  custom_data         = base64encode(file("${path.module}/scripts/init.sh"))
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.key.public_key_openssh
  }

  computer_name                   = "nginx"
  admin_username                  = "adminuser"
  disable_password_authentication = true

  os_disk {
    name                 = "${var.name}-nginxdisk01" #this needs to be unique per location
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}
