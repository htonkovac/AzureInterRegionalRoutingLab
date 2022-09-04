module "vnet" {
  source              = "../"
  resource_group_name = "dummy"
  location            = "east us 2"
  vnet_name           = "dummy"
  address_space       = ["10.0.0.0/16"]
  subnets = {
    "a" : {
      name : "sub1"
      address_space : ["10.0.0.0/24"]
    },
    "a" : {
      name : "sub2"
      address_space : ["10.0.1.0/24"]
    }
  }
}

provider "azurerm" {
  features {}
}