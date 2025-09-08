variable "resource_group_name" {}
variable "location" {}
variable "env" {}
variable "common_tags" { type = map(string) }
variable "vnet_id" {}
variable "db_subnet_id" {}
variable "key_vault_name" {}
variable "key_vault_id" {}
