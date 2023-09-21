variable "COMPONENT" {}
variable "instancetype" {}
variable "REGION" {}
variable "keypair" {}
variable "amazonami" {}
variable "centos8ami" {}

variable "environment" {
  default = "test"
}

variable "email" {
  default = "i@jithendar.com"
}

variable "userid" {
  default = "jithendar"
}

variable "level" {
  default = "trainer"
}

variable "vpc_cidr" {
  description = "CIDR Block for VPC"
  default     = "10.0.0.0/16"
}

variable "key_pair_name" {
  default = "roboshopkey"
}

variable "rds_cluster" {
  default = {
    db_max_capacity            = "16"
    db_min_capacity            = "0.5"
    db_backup_retention_period = "7"
  }
}

variable "aws_elasticache_replication_group" {
  default = {
    port                    = 6379
    node_type               = "cache.t3.small" #"cache.m6g.xlarge"
    engine                  = "redis"
    engine_version          = "7.0" #"5.0.5" #"7.0"
    num_node_groups         = 1
    replicas_per_node_group = 1 // within 0 and 5.
  }
}

variable "kms_config" {
  description = <<HEREDOC
    Configuration used to create the KMS CMK to handle encryption.
    `policy`: JSON policy document. If no policy is specified, AWS gives the key a [default key policy](https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html#key-policy-default), effectively delgating access control to IAM policies and KMS grants.
    `deletion_window_in_days`: The number of days the KMS key is retained after a delete request is initiated. Must be between `7` and `30`, inclusive.
    `enable_key_rotation`: Whether automatic key rotation is enabled.
  HEREDOC
  default = {
    policy                  = null
    deletion_window_in_days = 7
    enable_key_rotation     = true
  }
  type = object({
    policy                  = string
    deletion_window_in_days = number
    enable_key_rotation     = bool
  })
}

variable "s3_lifecycle_config" {
  description = "Configuration used to create lifecycle policy for S3 buckets"
  default = {
    days                         = 90
    days_in_standard_IA          = 30
    days_in_glacier              = 60
    noncurrent_days              = 1
    days_abort_incomplete_upload = 7
  }
  type = object({
    days                         = number
    days_in_standard_IA          = number
    days_in_glacier              = number
    noncurrent_days              = number
    days_abort_incomplete_upload = number
  })
}