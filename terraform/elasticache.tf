output "redis_endpoints" {
  description = "Roboshop Elasticache Redis Cluster Endpoints"
  value = [
    aws_elasticache_replication_group.roboshop.primary_endpoint_address,
    aws_elasticache_replication_group.roboshop.reader_endpoint_address
  ]
}

resource "aws_elasticache_parameter_group" "roboshop" {
  name        = "${local.name_prefix}-elasticache-pg-${local.name_suffix}"
  family      = "redis7" #"redis5.0"
  description = "Redis default cluster parameter group"
}

resource "aws_elasticache_replication_group" "roboshop" {
  automatic_failover_enabled = true
  multi_az_enabled           = true
  apply_immediately          = true
  subnet_group_name          = aws_elasticache_subnet_group.roboshop.name
  replication_group_id       = "${local.name_prefix}-redis-cluster-${local.name_suffix}"
  description                = "${local.name_prefix}-redis-cluster-${local.name_suffix}"
  parameter_group_name       = aws_elasticache_parameter_group.roboshop.name
  port                       = var.aws_elasticache_replication_group["port"]
  node_type                  = var.aws_elasticache_replication_group["node_type"]
  engine                     = var.aws_elasticache_replication_group["engine"]
  engine_version             = var.aws_elasticache_replication_group["engine_version"]
  num_node_groups            = var.aws_elasticache_replication_group["num_node_groups"]
  replicas_per_node_group    = var.aws_elasticache_replication_group["replicas_per_node_group"]
  at_rest_encryption_enabled = true
  transit_encryption_enabled = false //TODO Enable encryption 
  #  auth_token                 = var.elasticache_auth_token //only supported when encryption-in-transit
  kms_key_id         = aws_kms_key.roboshop.arn
  security_group_ids = [aws_security_group.roboshop.id]
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.roboshop_redis_logs.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }
  tags = (merge(local.common_tags, tomap({
    "Name"    = "${local.name_prefix}-redis-cluster-${local.name_suffix}",
    "Purpose" = "${local.common_tags["Team"]} redis cluster"
  })))
}

//records = [aws_elasticache_cluster.redis.cache_nodes[0].address]  endpoint wont be der..so using cache nodes... and cache node will have id, address, port and availability_zone information