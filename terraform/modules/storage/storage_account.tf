# Generate random string
resource "random_string" "random" {
  length  = 4
  upper   = false
  special = false
}

# Create a File Storage Account 
resource "azurerm_storage_account" "nfs_sa" {
  name                     = "nfsstorageacct${random_string.random.id}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Premium"
  account_replication_type = "ZRS"
  account_kind             = "FileStorage"

  tags = local.module_tags
}