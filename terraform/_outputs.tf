output "private_key" {
  value     = tls_private_key.roboshop.private_key_pem
  sensitive = true
}