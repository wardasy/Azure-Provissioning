terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.2.0"
    }
  }
}
provider "azurerm" {
  features {}
}
# Create a new resource group
resource "azurerm_resource_group" "new-group" {
  name     = "new-group"
  location = "Central US"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "New-Vnet" {
  name                = "New-Vnet"
  resource_group_name = azurerm_resource_group.new-group.name
  location            = azurerm_resource_group.new-group.location
  address_space       = ["10.0.0.0/16"]
}
# Create first subnet 
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.new-group.name
  virtual_network_name = azurerm_virtual_network.New-Vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
#create public ip 
resource "azurerm_public_ip" "test-public-ip" {
  name                    = "test-pip"
  location                = azurerm_resource_group.new-group.location
  resource_group_name     = azurerm_resource_group.new-group.name
  allocation_method       = "Dynamic"
}
#create network inerface
resource "azurerm_network_interface" "new-interface" {
  name                = "new-interface"
  resource_group_name = azurerm_resource_group.new-group.name
  location            = azurerm_resource_group.new-group.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.test-public-ip.id
  
  }
}
#create first windows vm
resource "azurerm_windows_virtual_machine" "Windows1" {
  name                            = "Windows1"
  resource_group_name             = azurerm_resource_group.new-group.name
  location                        = azurerm_resource_group.new-group.location
  size                            = "Standard_E2bds_v5"
  admin_username                  = "warda"
  admin_password                  = "Warda123Warda"

  network_interface_ids = [
    azurerm_network_interface.new-interface.id
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter-smalldisk-g2"
    version   = "latest"
  }
}
# Create second subnet 
resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = azurerm_resource_group.new-group.name
  virtual_network_name = azurerm_virtual_network.New-Vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
#create second public ip 
resource "azurerm_public_ip" "second-public-ip" {
  name                    = "second-pip"
  location                = azurerm_resource_group.new-group.location
  resource_group_name     = azurerm_resource_group.new-group.name
  allocation_method       = "Dynamic"
}
#create network inerface
resource "azurerm_network_interface" "interface2" {
  name                = "interface2"
  resource_group_name = azurerm_resource_group.new-group.name
  location            = azurerm_resource_group.new-group.location

  ip_configuration {
    name                          = "internal2"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.second-public-ip.id
  }
}
resource "azurerm_windows_virtual_machine" "Windows2" {
  name                            = "Windows2"
  resource_group_name             = azurerm_resource_group.new-group.name
  location                        = azurerm_resource_group.new-group.location
  size                            = "Standard_E2bds_v5"
  admin_username                  = "warda2"
  admin_password                  = "Warda123Warda"

  network_interface_ids = [
    azurerm_network_interface.interface2.id
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter-smalldisk-g2"
    version   = "latest"
  }
}
