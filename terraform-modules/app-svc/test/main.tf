resource "azurerm_resource_group" "x" {
  location = "East Us 2"
  name     = "appsvctest1234"
}

module "appsvc" {
  source              = "../"
  name                = "appsvctest-henry-1237"
  resource_group_name = azurerm_resource_group.x.name
  location            = azurerm_resource_group.x.location
}



provider "azurerm" {
  features {}
}