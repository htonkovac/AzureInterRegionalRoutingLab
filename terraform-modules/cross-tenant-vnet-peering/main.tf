
resource "azurerm_virtual_network_peering" "vnet_peer_0" {
  name                         = "my-side-of-the-peering"
  resource_group_name          = "peering-test"
  virtual_network_name         = "peering-test"
  remote_virtual_network_id    = "/subscriptions/73616d3d-e2fe-4423-baa3-098e5c1f5854/resourceGroups/RG1-MARTIN/providers/Microsoft.Network/virtualNetworks/VN1-MARTIN"
  
  allow_virtual_network_access = true #these booleans need checking, setting all to true just for testing
  allow_forwarded_traffic      = true
  use_remote_gateways          = true


}

provider "azurerm" {
    features {}
    tenant_id = "8e953d8a-9e3e-43f1-9733-a543ce604944"
    subscription_id = "8c581abc-4029-48af-ad32-5eabd64a4fe9" #otherwise I get an error Subscription ID must be configured when authenticating as a Service Principal using a Multi Tenant Client Secret.
  auxiliary_tenant_ids = ["5a76021a-ff77-411c-af5f-dd11aa577cd1"]
}