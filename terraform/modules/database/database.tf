# Generate random string
resource "random_string" "random" {
  length  = 5
  upper   = false
  special = false
}

# --- Private DNS zone for MySQL Flexible (used by VNet Integration) ---
resource "azurerm_private_dns_zone" "mysql_plz" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql_plz_link" {
  name                  = "mysql-plz-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.mysql_plz.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

# --- MySQL Flexible Server (Private access / VNet Integration) ---
resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "mysql-flex-${random_string.random.result}"
  resource_group_name    = var.resource_group_name
  location               = var.location

  administrator_login    = local.sql_admin_username
  administrator_password = local.sql_admin_password

  # VNet integration: Private-access
  delegated_subnet_id    = var.db_subnet_id
  private_dns_zone_id    = azurerm_private_dns_zone.mysql_plz.id

  sku_name               = "B_Standard_B1ms"  
  backup_retention_days  = 7
  version                = "8.0.21"
  # Ensure DNS link exists before server creation
  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql_plz_link]

lifecycle {
    ignore_changes = [
      administrator_login
    ]
  }
}

# --- Database on the server ---
resource "azurerm_mysql_flexible_database" "mysqldb" {
  name                = "mysqldb"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}
