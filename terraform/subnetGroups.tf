resource "aws_db_subnet_group" "roboshop" {
  name        = "roboshop-${var.environment}-rds-subnet-group"
  description = "Subnet Group for ${local.name_prefix} RDS cluster ${local.name_suffix}"
  subnet_ids  = aws_subnet.private_subnets.*.id
  tags = (merge(local.common_tags, tomap({
    "Name"    = "roboshop-${var.environment}-rds-subnet-group",
    "Purpose" = "aws_db_subnet_group for ${local.common_tags["Team"]}"
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