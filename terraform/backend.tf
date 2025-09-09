terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.43.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.2"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
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
#YOU CAN EITHER CREATE A REMOTE BACKEND ON TERRAFORM CLOUD OR WITH AN AZURE STORAGE ACCOUNTgit st.
#ALTERNATIVELY, YOU CAN SIMPLY CHOOSE TO USE A LOCAL BACKEND.
#EITHER WAY, YOU MUST CHANGE THIS BACKEND.
###########################################################################################
