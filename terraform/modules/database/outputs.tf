output "sql_admin_username" {
  value       = azurerm_mysql_flexible_server.mysql.administrator_login
  description = "SQL Admin username."
}
