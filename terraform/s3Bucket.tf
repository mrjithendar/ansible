resource "aws_s3_bucket" "roboshop" {
  bucket = "${local.name_prefix}-bucket-${local.name_suffix}"
  tags = (merge(local.common_tags, tomap({
    "Name"           = "${local.name_prefix}-bucket-${local.name_suffix}",
    "Purpose"        = "Roboshop bucket for ${local.common_tags["Team"]}",
    "ExpirationDate" = "Never",
    "SLA"            = "99.99",
    "NPI"            = "False"
  })))
}

resource "aws_s3_bucket_lifecycle_configuration" "input" {
  bucket = aws_s3_bucket.roboshop.id
  rule {
    id = "Roboshop s3 bucket policy"
    expiration {
      days = var.s3_lifecycle_config.days
    }
    noncurrent_version_expiration {
      noncurrent_days = var.s3_lifecycle_config.noncurrent_days
    }
    status = "Enabled"
    transition {
      days          = var.s3_lifecycle_config.days_in_standard_IA
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = var.s3_lifecycle_config.days_in_glacier
      storage_class = "GLACIER"
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = var.s3_lifecycle_config.days_abort_incomplete_upload
    }
  }
}

resource "aws_s3_bucket_versioning" "roboshop_versioning" {
  bucket = aws_s3_bucket.roboshop.id
  versioning_configuration {
    status = "Enabled"
  }
}

# resource "aws_s3_bucket_logging" "roboshop_logging" {
#   bucket        = aws_s3_bucket.roboshop.id
#   target_bucket = aws_s3_bucket.access_logs_bucket.id
#   target_prefix = "${aws_s3_bucket.roboshop.id}/"
#   depends_on    = [aws_s3_bucket.access_logs_bucket]
# }

resource "aws_s3_bucket_ownership_controls" "roboshop_ownership_controls" {
  bucket = aws_s3_bucket.roboshop.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "roboshop_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.roboshop_ownership_controls]
  bucket     = aws_s3_bucket.roboshop.id
  acl        = "private"
}

resource "aws_s3_bucket_public_access_block" "roboshop" {
  bucket                  = aws_s3_bucket.roboshop.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "roboshop_encryption" {
  bucket = aws_s3_bucket.roboshop.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.roboshop.id
    }
  }
}

# resource "aws_s3_bucket_policy" "roboshop_policy" {
#   bucket = aws_s3_bucket.roboshop.id
#   policy = data.aws_iam_policy_document.roboshop_policy_doc.json
# }

# data "aws_iam_policy_document" "roboshop_policy_doc" {
#   statement {
#     principals {
#       type = "AWS"
#       identifiers = [
#         "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
#         "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role"
#       ]
#     }
#     actions   = ["s3:*"]
#     resources = ["${aws_s3_bucket.roboshop.arn}/*", aws_s3_bucket.roboshop.arn]
#   }
# }

# resource "aws_s3_bucket_notification" "roboshop_notification" {
#   depends_on = [aws_s3_bucket.roboshop, aws_sqs_queue.bank_reporting_file_received_queue]
#   bucket     = aws_s3_bucket.roboshop.id
#   queue {
#     queue_arn     = aws_sqs_queue.bank_reporting_file_received_queue.arn
#     events        = ["s3:ObjectCreated:*"]
#     filter_prefix = "files/"
#   }
# }