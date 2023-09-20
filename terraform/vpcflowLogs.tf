# resource "aws_flow_log" "example" {
#   # default is cloudwatch can send to s3 and kinesis
#   iam_role_arn         = aws_iam_role.roboshop.arn
#   log_destination      = aws_s3_bucket.roboshop.arn
#   log_destination_type = "s3"
#   traffic_type         = "ALL"
#   vpc_id               = aws_vpc.roboshop.id
#   destination_options {
#     file_format        = "parquet"
#     per_hour_partition = true
#   }
#   tags = (merge(local.common_tags, tomap({
#     "Name"    = "${local.name_prefix}-vpc-flowlogs-${var.environment}",
#     "Purpose" = "vpc for ${local.common_tags["Team"]} vpc flowlogs"
#   })))
# }

data "aws_iam_policy_document" "vpcflowlogs" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "roboshop" {
  name               = "${local.name_prefix}-vpc-flowlogs-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.vpcflowlogs.json
  tags = (merge(local.common_tags, tomap({
    "Name"    = "${local.name_prefix}-vpc-flowlogs-role-${var.environment}",
    "Purpose" = "vpc for ${local.common_tags["Team"]} vpc flowlogs role"
  })))
}

data "aws_iam_policy_document" "vpcflowlogspolicy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "example" {
  name   = "${local.name_prefix}-vpc-flowlogs-policy-${var.environment}"
  role   = aws_iam_role.roboshop.id
  policy = data.aws_iam_policy_document.vpcflowlogspolicy.json
}