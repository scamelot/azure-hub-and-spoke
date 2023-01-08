resource "azurerm_subnet" "hubfwsubnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.hubnetwork.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "firewallpip" {
  name                = "firewallpip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "hubfirewall" {
  name                = "hubfirewall"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hubfwsubnet.id
    public_ip_address_id = azurerm_public_ip.firewallpip.id
  }
}

resource "azurerm_firewall_network_rule_collection" "fwrules" {
  name               = "fw-net-rcg"
  azure_firewall_name = azurerm_firewall.hubfirewall.name
  resource_group_name = azurerm_resource_group.main.name
  priority           = 200
  action   = "Allow"
    rule {
      name                  = "routetodev"
      protocols             = ["TCP", "UDP"]
      source_addresses      = ["10.2.0.0/16"]
      destination_addresses = ["10.1.0.0/16"]
      destination_ports     = ["*"]
    }
    rule {
      name                  = "routetotest"
      protocols             = ["TCP", "UDP"]
      source_addresses      = ["10.1.0.0/16"]
      destination_addresses = ["10.2.0.0/16"]
      destination_ports     = ["*"]
    }
    rule {
      name                  = "routetointernet"
      protocols             = ["TCP", "UDP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }
  }

#allows rdp from the internet - bad idea!
# resource "azurerm_firewall_nat_rule_collection" "fwnatrules" {
#   name               = "fw-nat-rcg"
#   azure_firewall_name = azurerm_firewall.hubfirewall.name
#   resource_group_name = azurerm_resource_group.main.name
#     priority = 199
#     action = "Dnat"
#     rule {
#       name                = "allowrdp"
#       protocols           = ["TCP"]
#       source_addresses    = ["*"]
#       destination_addresses = [azurerm_public_ip.firewallpip.ip_address]
#       destination_ports   = ["3389"]
#       #send RDP requests to dev vm
#       translated_address  = azurerm_windows_virtual_machine.devvm.private_ip_address
#       translated_port     = 3389
#     }
# }
