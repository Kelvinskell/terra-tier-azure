# Generate SSH Key pair for private instances and bastion connectivity
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# Upload private key to Key vault 
resource "azurerm_key_vault_secret" "ssh_private_key" {
  name         = "bastion-ssh-private-key"
  value        = tls_private_key.ssh.private_key_pem
  key_vault_id = var.key_vault_id 

  depends_on = [tls_private_key.ssh]
}
