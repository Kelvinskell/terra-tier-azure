/*data "azurerm_key_vault" "vault" {
    name = var.key_vault_name
    resource_group_name = var.resource_group_name
}*/

data "azurerm_key_vault_secret" "user" {
    name = "mysql-user"
    key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "pass" {
    name = "mysql-pass"
    key_vault_id = var.key_vault_id
}