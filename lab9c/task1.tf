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
  rg_name  = "az104-rg9c"
}

resource "azurerm_resource_group" "rg9c" {
  name     = local.rg_name
  location = local.location
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "az104-law"
  location            = azurerm_resource_group.rg9c.location
  resource_group_name = azurerm_resource_group.rg9c.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "env" {
  name                       = "my-environment-feniuk"
  location                   = azurerm_resource_group.rg9c.location
  resource_group_name        = azurerm_resource_group.rg9c.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
}

resource "azurerm_container_app" "app" {
  name                         = "my-app-feniuk"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg9c.name
  revision_mode                = "Single"

  template {
    container {
      name   = "my-app"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    external_enabled = true
    target_port      = 80

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}
