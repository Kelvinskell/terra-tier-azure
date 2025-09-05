terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 4.43.0"
    }
  }
  cloud {
    organization = "Org101"
    workspaces {
      name = "terra-tier-azure"
    }
  }
}