# Create Resource Group
resource "azurerm_resource_group" "example" {
  name     = "three-tier-rg"
  location = var.location

  tags = {
    Environment = var.env
  }
}