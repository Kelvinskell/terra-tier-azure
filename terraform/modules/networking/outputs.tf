output "vnet_id" {
  description = "ID of the VNet"
  value = azurerm_virtual_network.vnet.id
}

output "db_subnet_id" {
  description = "ID of one of the db subnets"
  value = azurerm_subnet.database_sub[local.db_subnet_keys[0]].id
}

output "private_subnet_id" {
  description = "ID of one of the private subnets"
  value = azurerm_subnet.private_sub[local.private_subnet_keys[0]].id
}

output "bastion_subnet_id" {
  description = "ID of the bastion subnet"
  value = azurerm_subnet.bastion_sub.id
}

output "pip-bastion" {
  description = "The public IP to be used by Azure Bastion"
  value = azurerm_public_ip.pub_ip_bastion.id
}

output "pip-appgw" {
  description = "The public IP to be used by App Gateway"
  value = azurerm_public_ip.pub_ip_app.id
}
