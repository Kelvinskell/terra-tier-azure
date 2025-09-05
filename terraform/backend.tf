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

##########################################################################################
#YOU MUST CHANGE THE ABOVE BACKEND TO YOUR OWN BACKEND IF YOU WANT THIS TO WORK FOR YOU.
#YOU CAN EITHER CREATE A REMOTE BACKEND ON TERRAFORM CLOUD OR WITH AN AZURE STORAGE ACCOUNT.
#ALTERNATIVELY, YOU CAN SIMPLY CHOOSE TO USE A LOCAL BACKEND.
#EITHER WAY, YOU MUST CHANGE THIS BACKEND.
###########################################################################################