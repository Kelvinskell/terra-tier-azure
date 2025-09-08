variable "location" {
  type    = string
  default = "westeurope"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "common_tags" {
  type    = map(string)
  default = { ManagedBy = "Terraform" }
}