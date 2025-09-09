variable "resource_group_name" {}
variable "location" {}
variable "env" {}
variable "common_tags" { type = map(string) }
variable "bastion_subnet_id" {}
variable "bastion_pip_id" {}
variable "private_subnet_id" {}
variable "key_vault_id" {}
variable "storage_account_name" {}
variable "fileshare_name" {}
variable "backend_addr_pool_id" {}
variable "mysqlvault_name" {}