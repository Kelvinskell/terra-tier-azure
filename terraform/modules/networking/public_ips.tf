# Create public IP for NAT Gateway
resource "azurerm_public_ip" "pub_ip_nat" {
  name                = "natgw_public_ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku               = "Standard"

  tags = local.module_tags
}

# Create public IP for App Gateway
resource "azurerm_public_ip" "pub_ip_app" {
  name                = "appgw_public_ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku               = "Standard"

  tags = local.module_tags
}