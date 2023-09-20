resource "aws_rds_cluster_parameter_group" "roboshop" {
  name        = "mysql-cluster-parameter-group-${var.environment}-roboshop"
  family      = "aurora-mysql5.7"
  description = "RDS default cluster parameter group"
  lifecycle {
    create_before_destroy = true
  }
  parameter {
    name  = "log_statement"
    value = "all"
  }
#   parameter {
#     name  = "log_min_duration_statement"
#     value = "1"
#   }
}

resource "aws_db_parameter_group" "roboshop" {
  depends_on = [aws_rds_cluster.roboshop]
  name       = "db-parameter-group-${var.environment}-roboshop"
  family     = "aurora-postgresql15"
  parameter {
    name  = "log_connections"
    value = "1"
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = (merge(local.common_tags, tomap({
    "Name"    = "db-parameter-group-${var.environment}-roboshop",
    "Purpose" = "aws_db_parameter_group for ${local.common_tags["Team"]}"
  })))
}

resource "aws_rds_cluster" "roboshop" {
  cluster_identifier              = "mysql-cluster-${var.environment}-roboshop"
  engine                          = "aurora-mysql"
  engine_version                  = "5.7.mysql_aurora.2.07.9" #old "5.7.mysql_aurora.2.03.2"
  database_name                   = "roboshopdb"
  master_username                 = jsondecode(data.aws_secretsmanager_secret_version.rdscreds.secret_string)["SSH_USER"]
  master_password                 = jsondecode(data.aws_secretsmanager_secret_version.rdscreds.secret_string)["SSH_PASS"]
  backup_retention_period         = 5
  preferred_backup_window         = "07:00-09:00"
  skip_final_snapshot             = true
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.roboshop.name
  vpc_security_group_ids          = [ aws_security_group.rdssg.id ]
}

resource "aws_rds_cluster_instance" "writer" {
  depends_on                            = [aws_db_parameter_group.roboshop]
  auto_minor_version_upgrade            = true
  identifier                            = "${local.name_prefix}-rds-cluster-rw-instance-${local.name_suffix}"
  instance_class                        = "db.serverless"
  cluster_identifier                    = aws_rds_cluster.roboshop.id
  db_parameter_group_name               = aws_db_parameter_group.roboshop.name
  db_subnet_group_name                  = aws_db_subnet_group.roboshop.name
  engine                                = "aurora-postgresql"
  monitoring_interval                   = 5
  monitoring_role_arn                   = aws_iam_role.rds_monitoring_role.arn
  publicly_accessible                   = false
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
  engine                                = "aurora-postgresql"
  monitoring_interval                   = 5
  monitoring_role_arn                   = aws_iam_role.rds_monitoring_role.arn
  publicly_accessible                   = false
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  tags = (merge(local.common_tags, tomap({
    "Name"    = "${local.name_prefix}-aws_rds_cluster_ro_instance-${local.name_suffix}",
    "Purpose" = "aws_rds_cluster_ro_instance for ${local.common_tags["Team"]}"
  })))
}

resource "null_resource" "import-mysql-schema" {
  provisioner "local-exec" {
    command = <<EOF
    sleep 600
    mysql -h ${aws_rds_cluster.roboshop.endpoint} -u${jsondecode(data.aws_secretsmanager_secret_version.rdscreds.secret_string)["SSH_USER"]} -p${jsondecode(data.aws_secretsmanager_secret_version.rdscreds.secret_string)["SSH_PASS"]} < _databases/shipping.sql
    EOF
  }
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