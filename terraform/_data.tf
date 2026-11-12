# Base OS for every component host: Rocky Linux 9 (official AMI).
# Override ami_owner / ami_name_filter to use your own golden image.
data "aws_ami" "ami" {
  most_recent = true
  owners      = [var.ami_owner]
  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

// pull secrets
data "aws_secretsmanager_secret" "rdscreds" {
  name = "rdscreds"
}

data "aws_secretsmanager_secret_version" "rdscreds" {
  secret_id = data.aws_secretsmanager_secret.rdscreds.id
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "azs" {
  # excluded us-east-1e availability zone
  exclude_names = ["us-east-1e"]
}


data "cloudflare_zone" "jithendar" {
  name = "jithendar.com"
}
