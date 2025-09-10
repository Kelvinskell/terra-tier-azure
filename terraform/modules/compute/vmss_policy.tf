# Create access policy for VM to access key vault
resource "azurerm_key_vault_access_policy" "vmss_policy" {
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    =azurerm_linux_virtual_machine_scale_set.vmss.identity[0].principal_id

  key_permissions = [
    "Get",
    "List"
  ]

  secret_permissions = [
    "Get",
    "List"
  ]
}