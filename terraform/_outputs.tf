# output "private_key" {
#   value     = tls_private_key.roboshop.private_key_pem
#   sensitive = true
# }

output "rds_endpoints" {
  description = "Roboshop RDS Cluster Endpoints"
  value = [
    aws_rds_cluster.roboshop.endpoint,
    aws_rds_cluster.roboshop.reader_endpoint
  ]
}

output "redis_endpoints" {
  description = "Roboshop Elasticache Redis Cluster Endpoints"
  value = [
    aws_elasticache_replication_group.roboshop.primary_endpoint_address,
    aws_elasticache_replication_group.roboshop.reader_endpoint_address
  ]
}