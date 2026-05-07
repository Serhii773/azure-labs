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
  rg_name  = "az104-rg9"
  app_name = "az104-webapp-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "rg9" {
  name     = local.rg_name
  location = local.location
}

resource "azurerm_service_plan" "app_plan" {
  name                = "az104-app-plan"
  location            = azurerm_resource_group.rg9.location
  resource_group_name = azurerm_resource_group.rg9.name
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "webapp" {
  name                = local.app_name
  location            = azurerm_resource_group.rg9.location
  resource_group_name = azurerm_resource_group.rg9.name
  service_plan_id     = azurerm_service_plan.app_plan.id

  site_config {
    application_stack {
      php_version = "8.2"
    }
  }
}
