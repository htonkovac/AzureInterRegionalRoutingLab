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

  /* 
     admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  
   computer_name = "nginx"
   admin_username = "adminuser"
   disable_password_authentication = true */
  computer_name                   = "nginx"
  admin_username                  = "adminuser"
  admin_password                  = "Faizan@bashir.123"
  disable_password_authentication = false

  os_disk {
    name                 = "nginxdisk01"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}
