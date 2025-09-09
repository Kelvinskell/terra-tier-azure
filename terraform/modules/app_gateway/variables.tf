variable "resource_group_name" {}
variable "location" {}
variable "env" {}
variable "common_tags" { type = map(string) }
variable "public_subnet_id" {}
variable "vnet_name" {}
variable "appgw-pip" {}