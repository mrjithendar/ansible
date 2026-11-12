variable "COMPONENT" {
  description = "RoboShop components that get their own EC2 instance. Must include \"frontend\"."
  type        = list(string)

  validation {
    condition     = contains(var.COMPONENT, "frontend")
    error_message = "COMPONENT must include \"frontend\" (the Cloudflare record points at it)."
  }
}

variable "instancetype" {
  description = "EC2 instance type for the RoboShop component hosts."
  type        = string
  default     = "t3.micro"
}

variable "REGION" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "ami_owner" {
  description = "AWS account that publishes the base AMI. Default is the official Rocky Linux publisher."
  type        = string
  default     = "792107900819"
}

variable "ami_name_filter" {
  description = "Name filter for the base AMI (the most recent match is used)."
  type        = string
  default     = "Rocky-9-EC2-Base-9.*x86_64*"
}

variable "environment" {
  description = "Environment name, used in resource names and tags."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "environment must be lowercase letters, digits and dashes."
  }
}

variable "email" {
  description = "Owner email for tagging."
  type        = string
}

variable "userid" {
  description = "Owner user id for tagging."
  type        = string
}

variable "key_pair_name" {
  description = "Name of the EC2 key pair Terraform creates for SSH access."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the RoboShop VPC (a /16 is expected; subnets are carved as /24s)."
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

variable "admin_cidrs" {
  description = "CIDRs allowed to SSH to the instances: your Jenkins agent and workstation public IPs, e.g. [\"203.0.113.10/32\"]."
  type        = list(string)

  validation {
    condition     = length(var.admin_cidrs) > 0 && alltrue([for c in var.admin_cidrs : can(cidrhost(c, 0)) && c != "0.0.0.0/0"])
    error_message = "Set admin_cidrs to valid, specific CIDRs (your Jenkins agent / workstation IPs). 0.0.0.0/0 is not allowed."
  }
}

variable "level" {
  description = "Optional extra Level tag."
  type        = string
  default     = ""
}

variable "rds_cluster" {
  description = "Aurora MySQL Serverless v2 settings."
  type = object({
    db_max_capacity            = number
    db_min_capacity            = number
    db_backup_retention_period = number
    database_name              = string
  })
  default = {
    db_max_capacity            = 16
    db_min_capacity            = 0.5
    db_backup_retention_period = 7
    database_name              = "roboshopdb"
  }
}

variable "aws_elasticache_replication_group" {
  description = "ElastiCache Redis settings."
  type = object({
    port                    = number
    node_type               = string
    engine                  = string
    engine_version          = string
    num_node_groups         = number
    replicas_per_node_group = number
  })
  default = {
    port                    = 6379
    node_type               = "cache.t3.small"
    engine                  = "redis"
    engine_version          = "7.0"
    num_node_groups         = 1
    replicas_per_node_group = 1
  }

  validation {
    condition     = var.aws_elasticache_replication_group.replicas_per_node_group >= 0 && var.aws_elasticache_replication_group.replicas_per_node_group <= 5
    error_message = "replicas_per_node_group must be between 0 and 5."
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

  validation {
    condition     = var.kms_config.deletion_window_in_days >= 7 && var.kms_config.deletion_window_in_days <= 30
    error_message = "deletion_window_in_days must be between 7 and 30."
  }
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
