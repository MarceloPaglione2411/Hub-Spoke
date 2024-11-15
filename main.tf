terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.28.0"
    }
     
    random = {
      source = "hashicorp/random"
      version = "3.4.3"
    }
  }
}

resource "random_password" "password" {
  count  = var.password == null ? 1 : 0
  length = 20
}

locals {
  password = try(random_password.password[0].result, var.password)
}