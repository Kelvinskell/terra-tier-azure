# Create Public Subnets
resource "azurerm_subnet" "public_sub" {
  for_each = local.public_subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value]
}

# Create Private Subnets
resource "azurerm_subnet" "private_sub" {
  for_each = local.private_subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value]
}

# Create Database Subnets
resource "azurerm_subnet" "database_sub" {
  for_each = local.database_subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value]

  delegation {
    name = "delegation"

    service_delegation {
      # Delegation for Azure Database for MySQL Flexible Server
      name = "Microsoft.DBforMySQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

# Create Bastion Subnet
resource "azurerm_subnet" "bastion_sub" {
  name                 = "AzureBastionSubnet" # must be exact
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.192/27"] 
}