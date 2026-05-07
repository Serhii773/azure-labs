terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
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
  rg_name  = "az104-rg7"
  vnet_ip  = ["10.0.0.0/16"]
  sub_ip   = ["10.0.1.0/24"]
}

data "http" "my_public_ip" {
  url = "https://ipv4.icanhazip.com"
}

resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "lab_rg" {
  name     = local.rg_name
  location = local.location
}

resource "azurerm_storage_account" "lab_storage" {
  name                          = "az104stor${random_integer.suffix.result}"
  resource_group_name           = azurerm_resource_group.lab_rg.name
  location                      = azurerm_resource_group.lab_rg.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = true

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.storage_subnet.id]
    ip_rules                   = [chomp(data.http.my_public_ip.response_body)]
  }
}

resource "azurerm_storage_management_policy" "lifecycle_rule" {
  storage_account_id = azurerm_storage_account.lab_storage.id

  rule {
    name    = "Movetocool"
    enabled = true

    filters {
      blob_types = ["blockBlob"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = 30
      }
    }
  }
}
