# Generate SSH Key pair for private instances and bastion connectivity
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}