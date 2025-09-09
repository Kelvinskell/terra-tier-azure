output "private_key_pem" {
    description = "The private key to be used by VM instances and bastion host"
    value = tls_private_key.ssh.private_key_pem
    sensitive = true
}

output "public_key_openssh" {
    description = "The public key to be used by VM instances and bastion host"
    value = tls_private_key.ssh.public_key_openssh
    sensitive = false
}

output "vmss_id" {
  description = "ID of the VMSS"
  value = azurerm_linux_virtual_machine_scale_set.vmss.id
}