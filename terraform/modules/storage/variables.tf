variable "resource_group_name" {}
variable "location" {}
variable "env" {}
variable "common_tags" { type = map(string) }
variable "private_subnet_id" {}
variable "vnet_id" {}