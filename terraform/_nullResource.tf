# resource "null_resource" "import-mysql-schema" {
#   depends_on = [ 
#     aws_rds_cluster_instance.reader,
#     aws_rds_cluster_instance.reader
#     ]
#   provisioner "local-exec" {
#     command = <<EOF
#     sleep 600
#     mysql -h ${aws_rds_cluster.roboshop.endpoint} -u${jsondecode(data.aws_secretsmanager_secret_version.rdscreds.secret_string)["SSH_USER"]} -p${jsondecode(data.aws_secretsmanager_secret_version.rdscreds.secret_string)["SSH_PASS"]} < _databases/shipping.sql
#     EOF
#   }
# }