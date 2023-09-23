#Centos-7-DevOps-Practice - ami-059e6ca6474628ef0

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["973714476881"]
  filter {
    name   = "name"
    values = ["Centos-7-DevOps-Practice"]
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

data "aws_subnets" "eks_subnets" {
  depends_on = [aws_subnet.private_subnets, aws_vpc.roboshop] #aws_subnet.public_subnets, 
  filter {
    name   = "vpc-id"
    values = [aws_vpc.roboshop.id]
  }
}

data "aws_availability_zones" "azs" {
  # excluded us-east-1e availability zone
  exclude_names = ["us-east-1e"]
}


data "cloudflare_zone" "jithendar" {
  name = "jithendar.com"
}