output "storage_account_name" {
    description = "The name of the storage account"
    value = azurerm_storage_account.nfs_sa.name
}

output "file_share_name" {
  description = "The name of the file share"
  value = azurerm_storage_share.nfs_share.name
}