# SSH from admin CIDRs only, plus all traffic between hosts inside the VPC
# (the app ports: 8080, 27017, 5672, ...). Attached to every component host.
resource "aws_security_group" "app" {
  name        = "roboshop-app-${var.environment}"
  description = "RoboShop hosts: SSH from admin CIDRs, any port from inside the VPC"
  vpc_id      = aws_vpc.roboshop.id

  ingress {
    description = "SSH from Jenkins agent / admin workstations"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.admin_cidrs
  }

  ingress {
    description = "All traffic from inside the VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.roboshop.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = (merge(local.common_tags, tomap({
    "Name"    = "roboshop-app-${var.environment}",
    "Purpose" = "Roboshop App ${local.common_tags["Team"]}"
  })))
}

# Public HTTP/HTTPS, attached to the frontend only.
resource "aws_security_group" "web" {
  name        = "roboshop-web-${var.environment}"
  description = "RoboShop frontend: HTTP/HTTPS from the internet"
  vpc_id      = aws_vpc.roboshop.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = (merge(local.common_tags, tomap({
    "Name"    = "roboshop-web-${var.environment}",
    "Purpose" = "Roboshop frontend ${local.common_tags["Team"]}"
  })))
}

# Managed data stores (Aurora MySQL, ElastiCache Redis): VPC-internal only.
resource "aws_security_group" "data" {
  name        = "roboshop-data-${var.environment}"
  description = "RoboShop RDS and ElastiCache: MySQL and Redis from inside the VPC"
  vpc_id      = aws_vpc.roboshop.id

  ingress {
    description = "Aurora MySQL from the VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.roboshop.cidr_block]
  }

  ingress {
    description = "Redis from the VPC"
    from_port   = var.aws_elasticache_replication_group.port
    to_port     = var.aws_elasticache_replication_group.port
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.roboshop.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.roboshop.cidr_block]
  }

  tags = (merge(local.common_tags, tomap({
    "Name"    = "roboshop-data-${var.environment}",
    "Purpose" = "Roboshop data stores ${local.common_tags["Team"]}"
  })))
}
