resource "azurerm_key_vault" "vault" {
  name                       = "mysqlvault"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
  tags = local.module_tags
}


resource "azurerm_key_vault_secret" "username" {
  name         = "mysql-user"
  value        = "sqladmin"
  key_vault_id = azurerm_key_vault.vault.id
}

resource "azurerm_key_vault_secret" "password" {
  name         = "mysql-pass"
  value        = random_password.sql_admin.result
  key_vault_id = azurerm_key_vault.vault.id
}