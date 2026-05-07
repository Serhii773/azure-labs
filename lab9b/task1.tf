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
  }
}

locals {
  location = "polandcentral"
  rg_name  = "az104-rg9b"
}

resource "azurerm_resource_group" "rg9b" {
  name     = local.rg_name
  location = local.location
}

resource "azurerm_container_group" "az104_c1" {
  name                = "az104-c1"
  location            = azurerm_resource_group.rg9b.location
  resource_group_name = azurerm_resource_group.rg9b.name
  ip_address_type     = "Public"
  dns_name_label      = "az104-c1-serhii"
  os_type             = "Linux"

  container {
    name   = "az104-c1"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }
}
