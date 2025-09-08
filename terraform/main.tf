# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "three-tier-rg"
  location = var.location

  tags = {
    Environment = var.env
  }
}

module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  env                 = var.env
  common_tags         = var.common_tags
}