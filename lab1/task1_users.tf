terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

provider "azuread" {}

data "azuread_domains" "default" {
  only_initial = true
}

data "azuread_client_config" "current" {}

# Task 1 - Створення користувача
resource "azuread_user" "user1" {
  user_principal_name = "az104-user1@${data.azuread_domains.default.domains[0].domain_name}"
  display_name        = "az104-user1"
  password            = "Pa$$w0rd123456!"
  job_title           = "IT Lab Administrator"
  department          = "IT"
  usage_location      = "US"
}

# Task 1 - Запрошення гостя
resource "azuread_invitation" "guest" {
  user_email_address = "serhii.feniuk.23@pnu.edu.ua"
  redirect_url       = "https://portal.azure.com"

  message {
    body = "Welcome to Azure and our group project"
  }
}
