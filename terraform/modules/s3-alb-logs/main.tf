# S3 Bucket for ALB Access Logs

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ELB service account for ALB logs
data "aws_elb_service_account" "main" {}

#checkov:skip=CKV_AWS_18:Access logging not required for logs bucket (would create circular dependency)
#checkov:skip=CKV_AWS_145:AES256 encryption acceptable for ALB logs; KMS not required
#checkov:skip=CKV2_AWS_62:Event notifications not required for ALB access logs
#checkov:skip=CKV_AWS_144:Cross-region replication not required for dev environment logs
resource "aws_s3_bucket" "alb_logs" {
  bucket = "${var.environment}-alb-logs-${data.aws_caller_identity.current.account_id}"

  lifecycle {
    prevent_destroy = false
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-alb-logs"
    }
  )
}

resource "aws_s3_bucket_versioning" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#checkov:skip=CKV_AWS_300:Incomplete multipart upload abort not required for ALB logs bucket
resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = var.log_retention_days
    }
  }
}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSLogDeliveryWrite"
        Effect = "Allow"
        Principal = {
          Service = "elasticloadbalancing.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/*"
      },
      {
        Sid    = "AWSLogDeliveryAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "elasticloadbalancing.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.alb_logs.arn
      }
    ]
  })
}
