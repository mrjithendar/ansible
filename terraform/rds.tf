output "rds_endpoints" {
  description = "Roboshop RDS Cluster Endpoints"
  value = [
    aws_rds_cluster.roboshop.endpoint,
    aws_rds_cluster.roboshop.reader_endpoint
  ]
}

resource "aws_rds_cluster_parameter_group" "roboshop" {
  name        = "mysql-cluster-parameter-group-${var.environment}-roboshop"
  family      = "aurora-mysql8.0" #"aurora-mysql5.7"
  description = "RDS default cluster parameter group"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_parameter_group" "roboshop" {
  name   = "db-parameter-group-${var.environment}-roboshop"
  family = "aurora-mysql8.0" #"aurora-mysql5.7"
  lifecycle {
    create_before_destroy = true
  }
  tags = (merge(local.common_tags, tomap({
    "Name"    = "db-parameter-group-${var.environment}-roboshop",
    "Purpose" = "aws_db_parameter_group for ${local.common_tags["Team"]}"
  })))
}

resource "aws_rds_cluster" "roboshop" {
  cluster_identifier                  = "mysql-cluster-${var.environment}-roboshop"
  engine                              = "aurora-mysql"
  engine_version                      = "8.0.mysql_aurora.3.04.0" #old "5.7.mysql_aurora.2.03.2"
  database_name                       = "roboshopdb"
  master_username                     = jsondecode(data.aws_secretsmanager_secret_version.rdscreds.secret_string)["SSH_USER"]
  master_password                     = jsondecode(data.aws_secretsmanager_secret_version.rdscreds.secret_string)["SSH_PASS"]
  backup_retention_period             = var.rds_cluster["db_backup_retention_period"]
  preferred_backup_window             = "07:00-09:00"
  skip_final_snapshot                 = true
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.roboshop.name
  db_subnet_group_name                = aws_db_subnet_group.roboshop.name
  vpc_security_group_ids              = [aws_security_group.roboshop.id]
  storage_encrypted                   = true
  iam_database_authentication_enabled = true
  apply_immediately                   = true
  serverlessv2_scaling_configuration {
    max_capacity = var.rds_cluster["db_max_capacity"]
    min_capacity = var.rds_cluster["db_min_capacity"]
  }
  lifecycle {
    ignore_changes = [availability_zones]
  }
  copy_tags_to_snapshot = true
  tags = (merge(local.common_tags, tomap({
    "Name"    = "${local.name_prefix}-aws_rds_cluster-${local.name_suffix}",
    "Purpose" = "RDS Cluster for ${local.common_tags["Team"]}"
  })))
}

resource "aws_rds_cluster_instance" "writer" {
  depends_on                            = [aws_db_parameter_group.roboshop]
  auto_minor_version_upgrade            = true
  identifier                            = "${local.name_prefix}-rds-cluster-rw-instance-${local.name_suffix}"
  instance_class                        = "db.serverless"
  cluster_identifier                    = aws_rds_cluster.roboshop.id
  db_parameter_group_name               = aws_db_parameter_group.roboshop.name
  db_subnet_group_name                  = aws_db_subnet_group.roboshop.name
  engine                                = "aurora-mysql"
  monitoring_interval                   = 5
  monitoring_role_arn                   = aws_iam_role.rds_monitoring_role.arn
  publicly_accessible                   = true # true/false
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  tags = (merge(local.common_tags, tomap({
    "Name"    = "${local.name_prefix}-aws_rds_cluster_rw_instance-${local.name_suffix}",
    "Purpose" = "aws_rds_cluster_rw_instance for ${local.common_tags["Team"]}"
  })))
}

resource "aws_rds_cluster_instance" "reader" {
  depends_on = [
    aws_rds_cluster_instance.writer,
    aws_db_parameter_group.roboshop
  ]
  auto_minor_version_upgrade            = true
  identifier                            = "${local.name_prefix}-rds-cluster-ro-instance-${local.name_suffix}"
  instance_class                        = "db.serverless"
  cluster_identifier                    = aws_rds_cluster.roboshop.id
  db_parameter_group_name               = aws_db_parameter_group.roboshop.name
  db_subnet_group_name                  = aws_db_subnet_group.roboshop.name
  engine                                = "aurora-mysql"
  monitoring_interval                   = 5
  monitoring_role_arn                   = aws_iam_role.rds_monitoring_role.arn
  publicly_accessible                   = true # true/false
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  tags = (merge(local.common_tags, tomap({
    "Name"    = "${local.name_prefix}-aws_rds_cluster_ro_instance-${local.name_suffix}",
    "Purpose" = "aws_rds_cluster_ro_instance for ${local.common_tags["Team"]}"
  })))
}

# RDS Monitoring Role
resource "aws_iam_role" "rds_monitoring_role" {
  name               = "${local.name_prefix}-rds_monitoring_role-${local.name_suffix}"
  assume_role_policy = data.aws_iam_policy_document.rds_monitoring_role_pd.json
  tags = (merge(local.common_tags, tomap({
    "Name"    = "${local.name_prefix}-rds_monitoring_role-${local.name_suffix}",
    "Purpose" = "rds_monitoring_role for ${local.common_tags["Team"]}"
  })))
}

data "aws_iam_policy_document" "rds_monitoring_role_pd" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "bank_reporting_rds_cluster_monitoring" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  role       = aws_iam_role.rds_monitoring_role.name
}