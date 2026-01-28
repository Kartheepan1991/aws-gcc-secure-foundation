# KMS Module - Encryption keys for GCC compliance
# Separate keys for different services following security best practices

# KMS Key for ECR encryption
resource "aws_kms_key" "ecr" {
  description             = "KMS key for ECR repository encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-ecr-kms-key"
      Service = "ECR"
    }
  )
}

resource "aws_kms_alias" "ecr" {
  name          = "alias/${var.environment}-ecr"
  target_key_id = aws_kms_key.ecr.key_id
}

# KMS Key for CloudWatch Logs encryption
resource "aws_kms_key" "cloudwatch" {
  description             = "KMS key for CloudWatch Logs encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.aws_account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${var.aws_region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:*"
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-cloudwatch-kms-key"
      Service = "CloudWatch"
    }
  )
}

resource "aws_kms_alias" "cloudwatch" {
  name          = "alias/${var.environment}-cloudwatch"
  target_key_id = aws_kms_key.cloudwatch.key_id
}

# KMS Key for S3 (Terraform state) encryption
resource "aws_kms_key" "s3" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-s3-kms-key"
      Service = "S3"
    }
  )
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${var.environment}-s3-state"
  target_key_id = aws_kms_key.s3.key_id
}

# KMS Key for ECS task definition encryption
resource "aws_kms_key" "ecs" {
  description             = "KMS key for ECS task secrets encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-ecs-kms-key"
      Service = "ECS"
    }
  )
}

resource "aws_kms_alias" "ecs" {
  name          = "alias/${var.environment}-ecs"
  target_key_id = aws_kms_key.ecs.key_id
}
