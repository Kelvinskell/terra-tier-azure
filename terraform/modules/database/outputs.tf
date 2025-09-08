output "sql_server_fqdn" {
  value       = azurerm_mssql_server.sql_server.fully_qualified_domain_name
  description = "DNS name of the SQL Server."
}

output "sql_admin_username" {
  value       = azurerm_mssql_server.sql_server.administrator_login
  description = "SQL Admin username."
}
