resource "azurerm_virtual_network" "devnetwork" {
  name                = "devnetwork"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "devsubnet" {
  name                 = "devsubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.devnetwork.name
  address_prefixes     = ["10.1.1.0/24"]

}

#VM config
resource "azurerm_network_interface" "devnic" {
  name                = "devnic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.devsubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "devvm" {
  name                = "devvm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.devnic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_route_table" "devrtb" {
  name                          = "devrtb"
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  disable_bgp_route_propagation = false

  route {
    name                   = "totest"
    address_prefix         = "10.2.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.hubfirewall.ip_configuration[0].private_ip_address
  }
  route {
    name                   = "internetbound"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.hubfirewall.ip_configuration[0].private_ip_address
  }

  tags = {
    environment = "Development"
  }
}

resource "azurerm_subnet_route_table_association" "devrtbassociation" {
  subnet_id      = azurerm_subnet.devsubnet.id
  route_table_id = azurerm_route_table.devrtb.id
}
