resource "aws_kms_alias" "roboshop" {
  name          = "alias/${local.name_prefix}-elasticache-replication-kms-key-alias-${local.name_suffix}"
  target_key_id = aws_kms_key.roboshop.id
}

resource "aws_kms_key" "roboshop" {
  description             = "Master key for the ${local.common_tags["Team"]} Roboshop Application"
  deletion_window_in_days = var.kms_config.deletion_window_in_days
  is_enabled              = true
  enable_key_rotation     = var.kms_config.enable_key_rotation
  policy                  = var.kms_config.policy
  tags = (merge(local.common_tags, tomap({
    "Name"    = "${local.name_prefix}-elasticache-replication-kms-key-${local.name_suffix}",
    "Purpose" = "Master key for ${local.common_tags["Team"]} Roboshop Application"
  })))
}