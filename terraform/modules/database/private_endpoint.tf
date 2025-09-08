resource "azurerm_private_dns_zone" "sql_pl" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name
  tags = local.module_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_pl_link" {
  name                  = "sql-plz-vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql_pl.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

resource "azurerm_private_endpoint" "sql_pe" {
  name                          = "pe-sqlserver"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.db_subnet_id
  custom_network_interface_name = "nic-pe-sqlserver"

  private_service_connection {
    name                           = "psc-sqlserver"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "sql-plz-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql_pl.id]
  }
  tags = local.module_tags
}