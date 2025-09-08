# Locals block for tags
locals {
  module_tags = merge(
    var.common_tags,
    { Env = var.env } 
  )
}

 locals {
  sql_admin_username = data.azurerm_key_vault_secret.user.value
  sql_admin_password = data.azurerm_key_vault_secret.pass.value
} 