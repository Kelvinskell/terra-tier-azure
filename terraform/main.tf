# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "three-tier-rg"
  location = var.location

  tags = {
    Environment = var.env
  }
}

module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  env                 = var.env
  common_tags         = var.common_tags
}

module "key_vault" {
  source = "./modules/key_vault"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  env                 = var.env
  common_tags         = var.common_tags
}

module "database" {
  source = "./modules/database"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  env                 = var.env
  common_tags         = var.common_tags
  vnet_id             = module.networking.vnet_id
  key_vault_id        = module.key_vault.key_vault_id
  key_vault_name      = module.key_vault.key_vault_name
  db_subnet_id        = module.networking.db_subnet_id

  depends_on = [module.key_vault]
}

module "storage" {
  source = "./modules/storage"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  env                 = var.env
  common_tags         = var.common_tags
  vnet_id             = module.networking.vnet_id
  private_subnet_id   = module.networking.private_subnet_id
}

module "compute" {
  source = "./modules/compute"

  resource_group_name  = azurerm_resource_group.rg.name
  location             = var.location
  env                  = var.env
  common_tags          = var.common_tags
  key_vault_id         = module.key_vault.key_vault_id
  private_subnet_id    = module.networking.private_subnet_id
  bastion_pip_id       = module.networking.pip-bastion
  bastion_subnet_id    = module.networking.bastion_subnet_id
  fileshare_name       = module.storage.file_share_name
  storage_account_name = module.storage.storage_account_name

  depends_on = [
    module.database,
    module.storage,
    module.networking,
    module.key_vault
  ]
}