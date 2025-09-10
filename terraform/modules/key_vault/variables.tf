variable "resource_group_name" {}
variable "location" {}
variable "env" {}
variable "common_tags" { type = map(string) }
variable "additional_user_upn" {
  description = "Optional UPN of a user to grant access to the Key Vault"
  type        = string
  default     = ""
validation {
    condition     = can(regex("^\\S+@\\S+\\.\\S+$", var.additional_user_upn)) || var.additional_user_upn == ""
    error_message = "The UPN must be a valid email address or an empty string."
  }
}