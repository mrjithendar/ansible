resource "tls_private_key" "roboshop" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "roboshop" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.roboshop.public_key_openssh
}

output "private_key" {
  value     = tls_private_key.roboshop.private_key_pem
  sensitive = true
}