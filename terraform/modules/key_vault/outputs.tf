output "key_vault_name" {
    description = "Name of the Azure key vault"
    value = azurerm_key_vault.vault.id
}

output "key_vault_id" {
    description = "Id of the Azure key vault"
    value = azurerm_key_vault.vault.id
}