# Create NFS File share
resource "azurerm_storage_share" "nfs_share" {
  name               = "nfs-share"
  storage_account_id = azurerm_storage_account.nfs_sa.id
  quota              = 1024        
  enabled_protocol   = "NFS"
}