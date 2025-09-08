
# Azure SQL Server (secure-by-default)
resource "azurerm_mssql_server" "sql_server" {
  name                         = "mysql-server"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = local.sql_admin_username
  administrator_login_password = local.sql_admin_password

  # Security hardening
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false   

  identity {
    type = "SystemAssigned"
  }

  tags = local.module_tags
}

# Azure MySQL Database
resource "azurerm_mssql_database" "mysql_db" {
  name         = "mysql-db"
  server_id    = azurerm_mssql_server.sql_server.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 2
  sku_name     = "S0"
  enclave_type = "VBS"
  tags = local.module_tags
  
  lifecycle {
    prevent_destroy = false
  }
}