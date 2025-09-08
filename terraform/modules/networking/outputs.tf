output "vnet_id" {
  description = "ID of the VNet"
  value = azurerm_virtual_network.vnet.id
}

output "db_subnet_id" {
  description = "ID of one of the db subnets"
  value = azurerm_subnet.database_sub[local.subnet_keys[0]].id
}