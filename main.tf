resource "azurerm_resource_group" "main" {
  name     = "mainnetwork"
  location = "eastus"
}

#hub-dev peerings
resource "azurerm_virtual_network_peering" "dev-to-hub-peer" {
  name                         = "devtohub"
  virtual_network_name         = azurerm_virtual_network.devnetwork.name
  remote_virtual_network_id    = azurerm_virtual_network.hubnetwork.id
  resource_group_name          = azurerm_resource_group.main.name
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "hub-to-dev-peer" {
  name                         = "hubtodev"
  virtual_network_name         = azurerm_virtual_network.hubnetwork.name
  remote_virtual_network_id    = azurerm_virtual_network.devnetwork.id
  resource_group_name          = azurerm_resource_group.main.name
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

#test-dev peerings
resource "azurerm_virtual_network_peering" "test-to-hub-peer" {
  name                         = "testtohub"
  virtual_network_name         = azurerm_virtual_network.testnetwork.name
  remote_virtual_network_id    = azurerm_virtual_network.hubnetwork.id
  resource_group_name          = azurerm_resource_group.main.name
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "hub-to-test-peer" {
  name                         = "hubtotest"
  virtual_network_name         = azurerm_virtual_network.hubnetwork.name
  remote_virtual_network_id    = azurerm_virtual_network.testnetwork.id
  resource_group_name          = azurerm_resource_group.main.name
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

#virtual WAN
# resource "azurerm_virtual_wan" "mainwan" {
#   name                = "main-virtualwan"
#   resource_group_name = azurerm_resource_group.main.name
#   location            = azurerm_resource_group.main.location
# }

# resource "azurerm_virtual_hub" "mainvhub" {
#   name                = "main-virtualhub"
#   resource_group_name = azurerm_resource_group.main.name
#   location            = azurerm_resource_group.main.location
#   virtual_wan_id      = azurerm_virtual_wan.mainwan.id
#   address_prefix      = "10.0.0.0/23"
# }





