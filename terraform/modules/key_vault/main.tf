# Generate random string
resource "random_string" "random" {
  length  = 4
  upper   = false
  special = false
}

# Create Key Vault
resource "azurerm_key_vault" "vault" {
  name                       = "mysqlvault${random_string.random.lower}"
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
      "List"
    ]

    secret_permissions = [
      "Set",
      "Get",
      "List",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
  tags = local.module_tags
  lifecycle {
    ignore_changes = all
  }
}

# Create additinal key vault access policy for user
data "azuread_user" "current_user" {
  count               = var.additional_user_upn != "" ? 1 : 0
  user_principal_name = var.additional_user_upn  
}

resource "azurerm_key_vault_access_policy" "user_policy" {
  count = var.additional_user_upn != "" ? 1 : 0
  key_vault_id = azurerm_key_vault.vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_user.current_user[0].object_id
  key_permissions = [
    "Get", "List"
  ]

  secret_permissions = [
    "Get", "List", "Set"
  ]
}

# Create Key vault secrets
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