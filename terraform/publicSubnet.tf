# public subnet
resource "aws_subnet" "public_subnet_1" {
  # count                   = length(data.aws_availability_zones.azs.names)
  vpc_id                  = aws_vpc.roboshop.id
  availability_zone       = random_shuffle.az_list.result[1]
  cidr_block              = "10.0.5.0/24" # "10.0.0.0/16"
  map_public_ip_on_launch = true
  tags = (merge(local.common_tags, tomap({
    "Name"                   = "${local.name_prefix}-public-subnet-1-${var.environment}-1",
    "Purpose"                = "${local.common_tags["Team"]} public subnet for roboshop app",
    "karpenter.sh/discovery" = "${local.name_prefix}-${local.name_suffix}"
  })))
}

resource "aws_subnet" "public_subnet_2" {
  # count                   = length(data.aws_availability_zones.azs.names)
  vpc_id                  = aws_vpc.roboshop.id
  availability_zone       = random_shuffle.az_list.result[0]
  cidr_block              = "10.0.6.0/24" # "10.0.0.0/16"
  map_public_ip_on_launch = true
  tags = (merge(local.common_tags, tomap({
    "Name"                   = "${local.name_prefix}-public-subnet-2-${var.environment}-1",
    "Purpose"                = "${local.common_tags["Team"]} public subnet for roboshop app",
    "karpenter.sh/discovery" = "${local.name_prefix}-${local.name_suffix}"
  })))
}