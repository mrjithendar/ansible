resource "aws_rds_cluster_parameter_group" "mysql" {
  name        = "mysql-cluster-parameter-group-${var.environment}-roboshop"
  family      = "aurora-mysql5.7"
  description = "RDS default cluster parameter group"
}

resource "aws_rds_cluster" "mysql" {
  cluster_identifier              = "mysql-cluster-${var.environment}-roboshop"
  engine                          = "aurora-mysql"
  engine_version                  =  "5.7.mysql_aurora.2.07.9" #old "5.7.mysql_aurora.2.03.2"
  database_name                   = "defaultdb"
  master_username                 = jsondecode(data.aws_secretsmanager_secret_version.rdscreds.secret_string)["SSH_USER"]
  master_password                 = jsondecode(data.aws_secretsmanager_secret_version.rdscreds.secret_string)["SSH_PASS"]
  backup_retention_period         = 5
  preferred_backup_window         = "07:00-09:00"
  skip_final_snapshot             = true
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.mysql.name
  vpc_security_group_ids          = [ aws_security_group.roboshop.id ]
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 1
  identifier         = "mysql-server-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.mysql.id
  instance_class     = "db.t3.small"
  engine             = aws_rds_cluster.mysql.engine
  engine_version     = aws_rds_cluster.mysql.engine_version
}

resource "null_resource" "import-mysql-schema" {
  provisioner "local-exec" {
    command = <<EOF
    sleep 600
    mysql -h ${aws_rds_cluster.mysql.endpoint} -u${jsondecode(data.aws_secretsmanager_secret_version.rdscreds.secret_string)["SSH_USER"]} -p${jsondecode(data.aws_secretsmanager_secret_version.rdscreds.secret_string)["SSH_PASS"]} < _databases/shipping.sql
    EOF
  }
}