# output "private_key" {
#   value     = tls_private_key.roboshop.private_key_pem
#   sensitive = true
# }

output "redis" {
  value = aws_elasticache_cluster.redis.cache_nodes[0].address
}