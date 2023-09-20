resource "aws_cloudwatch_log_group" "roboshop_redis_logs" {
  name              = "${local.name_prefix}-redis-cluster-logs-${local.name_suffix}"
  retention_in_days = 90
#   kms_key_id        = aws_kms_key.roboshop.arn
  tags = (merge(local.common_tags, tomap({
    "Name"    = "${local.name_prefix}-redis-cluster-logs-${local.name_suffix}",
    "Purpose" = "${local.common_tags["Team"]} Roboshop redis logs"
  })))
}