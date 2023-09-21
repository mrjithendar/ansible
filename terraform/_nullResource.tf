resource "null_resource" "extract_database" {
  // unzip the databse sql file
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "unzip -o _databases/shipping.zip"
  }
}

resource "null_resource" "wait_for_rds" {
  // wait for the RDS to be ready
  # triggers = {
  #   always_run = "${timestamp()}"
  # }
  provisioner "local-exec" {
    command = "sleep 600"
  }
}

resource "null_resource" "import_shipping_db" {
  // Import databse into RDS 
  depends_on = [ 
    aws_rds_cluster_instance.reader,
    aws_rds_cluster_instance.reader,
    null_resource.extract_database,
    null_resource.wait_for_rds
    ]
  provisioner "local-exec" {
    command = <<EOF
    mysql -h ${aws_rds_cluster.roboshop.endpoint} -u${jsondecode(data.aws_secretsmanager_secret_version.rdscreds.secret_string)["SSH_USER"]} -p${jsondecode(data.aws_secretsmanager_secret_version.rdscreds.secret_string)["SSH_PASS"]} < shipping.sql
    EOF
  }
}