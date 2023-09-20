resource "aws_elasticache_parameter_group" "redis" {
  name        = "redis-cluster-parameter-group-${var.environment}-roboshop"
  family      = "redis5.0"
  description = "Redis default cluster parameter group"
  tags = (merge(local.common_tags, tomap({
    "Name"    = "redis-cluster-parameter-group-${var.environment}-roboshop",
    "Purpose" = "Roboshop App Component ${local.common_tags["Team"]}"
  })))
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "redis-subnetgroup-${var.environment}-roboshop"
  subnet_ids = aws_subnet.private_subnets.*.id
  tags = (merge(local.common_tags, tomap({
    "Name"    = "redis-subnetgroup-${var.environment}-roboshop",
    "Purpose" = "Roboshop App Component ${local.common_tags["Team"]}"
  })))
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "redis-${var.environment}-roboshop"
  engine               = "redis"
  node_type            = "cache.t3.small"
  num_cache_nodes      = 1
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  parameter_group_name = aws_elasticache_parameter_group.redis.name
  engine_version       = "5.0.5"
  port                 = 6379
  tags = (merge(local.common_tags, tomap({
    "Name"    = "redis-${var.environment}-roboshop",
    "Purpose" = "Roboshop App Component ${local.common_tags["Team"]}"
  })))
}

//records = [aws_elasticache_cluster.redis.cache_nodes[0].address]  endpoint wont be der..so using cache nodes... and cache node will have id, address, port and availability_zone information