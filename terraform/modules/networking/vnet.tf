resource "azurerm_virtual_network" "vnet" {
  name                = "example-network"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/24"]

  tags = local.module_tags
}