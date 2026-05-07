terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.116.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    virtual_machine {
      delete_os_disk_on_deletion = true
    }
  }
}

locals {
  location       = "polandcentral"
  rg_name        = "az104-rg11"
  admin_username = "localadmin"
  admin_password = "P@ssw0rd1234!"
}

resource "azurerm_resource_group" "rg11" {
  name     = local.rg_name
  location = local.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "az104-11-vnet"
  location            = azurerm_resource_group.rg11.location
  resource_group_name = azurerm_resource_group.rg11.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg11.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "az104-11-vm0-nic"
  location            = azurerm_resource_group.rg11.location
  resource_group_name = azurerm_resource_group.rg11.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm0" {
  name                = "az104-vm0"
  resource_group_name = azurerm_resource_group.rg11.name
  location            = azurerm_resource_group.rg11.location
  size                = "Standard_B2als_v2"
  admin_username      = local.admin_username
  admin_password      = local.admin_password

  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-g2"
    version   = "latest"
  }
}
