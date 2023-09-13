resource "aws_vpc" "roboshop" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  # Must be enabled for EFS
  enable_dns_support   = true
  enable_dns_hostnames = true
  lifecycle {
    create_before_destroy = true
  }
  tags = (merge(local.common_tags, tomap({
    "Name"    = "${local.name_prefix}-roboshop-vpc-${var.environment}",
    "Purpose" = "vpc for ${local.common_tags["Team"]} vpc for eks"
  })))
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.roboshop.id
  tags = (merge(local.common_tags, tomap({
    "Name"    = "${local.name_prefix}-roboshop-igw-${var.environment}",
    "Purpose" = "Key for ${local.common_tags["Team"]} igw for roboshop app"
  })))
}

resource "aws_subnet" "private_subnets" {
  ## Private Subnets
  count                   = length(data.aws_availability_zones.azs.names)
  vpc_id                  = aws_vpc.roboshop.id
  availability_zone       = random_shuffle.az_list.result[count.index]
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index) # "10.0.0.0/16"
  map_public_ip_on_launch = false

  tags = (merge(local.common_tags, tomap({
    "Name"                   = "${local.name_prefix}-roboshop-subnet-${var.environment}-${count.index + 1}",
    "Purpose"                = "${local.common_tags["Team"]} subnet for roboshop app",
    "karpenter.sh/discovery" = "${local.name_prefix}-roboshop-${local.name_suffix}"
  })))
}

resource "aws_eip" "eip" {
  # vpc = true
  tags = (merge(local.common_tags, tomap({
    "Name"    = "${local.name_prefix}-eip-${var.environment}",
    "Purpose" = "${local.common_tags["Team"]} eip"
  })))
}

resource "aws_route_table" "pr_rt" {
  vpc_id = aws_vpc.roboshop.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }
  tags = (merge(local.common_tags, tomap({
    "Name"    = "${local.name_prefix}-private-rt-${var.environment}",
    "Purpose" = "${local.common_tags["Team"]} private route table"
  })))
}

resource "aws_route_table_association" "pr_rta" {
  count          = length(data.aws_availability_zones.azs.names)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.pr_rt.id
}

# public subnet
resource "aws_subnet" "public_subnets" {
  # count                   = length(data.aws_availability_zones.azs.names)
  vpc_id                  = aws_vpc.roboshop.id
  availability_zone       = random_shuffle.az_list.result[1]
  cidr_block              = "10.0.5.0/24" # "10.0.0.0/16"
  map_public_ip_on_launch = true
  tags = (merge(local.common_tags, tomap({
    "Name"                   = "${local.name_prefix}-roboshop-public-subnet-${var.environment}-1",
    "Purpose"                = "${local.common_tags["Team"]} public subnet for roboshop app",
    "karpenter.sh/discovery" = "${local.name_prefix}-roboshop-${local.name_suffix}"
  })))
}

resource "aws_nat_gateway" "ngw" {
  connectivity_type = "public" # default is "public" can be private too
  allocation_id     = aws_eip.eip.id
  subnet_id         = aws_subnet.public_subnets.id
  tags = (merge(local.common_tags, tomap({
    "Name"    = "${local.name_prefix}-nat-gateway-1-${var.environment}",
    "Purpose" = "${local.common_tags["Team"]} nat gateway"
  })))
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "pl_rt" {
  vpc_id = aws_vpc.roboshop.id
  route {
    cidr_block = "0.0.0.0/0" # aws_vpc.roboshop.cidr_block 
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = (merge(local.common_tags, tomap({
    "Name"    = "${local.name_prefix}-public-rt-${var.environment}",
    "Purpose" = "${local.common_tags["Team"]} public route table"
  })))
}

resource "aws_route_table_association" "pl_rta" {
  count          = length(data.aws_availability_zones.azs.names)
  subnet_id      = aws_subnet.public_subnets.id
  route_table_id = aws_route_table.pl_rt.id
}