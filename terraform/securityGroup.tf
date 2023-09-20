resource "aws_security_group" "roboshop" {
  name        = "Roboshop-SG"
  description = "Allow TLS/HTTP/SSH inbound traffic"
  vpc_id      = aws_vpc.roboshop.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #[aws_vpc.roboshop.cidr_block]
    # ipv6_cidr_blocks = [aws_vpc.roboshop.ipv6_cidr_block]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #[aws_vpc.roboshop.cidr_block]
    # ipv6_cidr_blocks = [aws_vpc.roboshop.ipv6_cidr_block]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #[aws_vpc.roboshop.cidr_block]
    # ipv6_cidr_blocks = [aws_vpc.roboshop.ipv6_cidr_block]
  }

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = (merge(local.common_tags, tomap({
    "Name"    = "Roboshop-SG",
    "Purpose" = "Roboshop App ${local.common_tags["Team"]}"
  })))
}

resource "aws_security_group" "rdssg" {
  name   = "roboshop-${var.environment}-rds-security-group"
  vpc_id = aws_vpc.roboshop.id
  ingress {
    description = "Allow TCP Traffic from EKS VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = aws_vpc.roboshop.cidr_block_associations.*.cidr_blocks
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = (merge(local.tags, tomap({
    "Name"    = "roboshop-${var.environment}-rds-security-group",
    "Purpose" = "${local.tags["Team"]} security group RDS cluster"
  })))
}