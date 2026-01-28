output "ecr_kms_key_id" {
  description = "KMS key ID for ECR"
  value       = aws_kms_key.ecr.key_id
}

output "ecr_kms_key_arn" {
  description = "KMS key ARN for ECR"
  value       = aws_kms_key.ecr.arn
}

output "cloudwatch_kms_key_id" {
  description = "KMS key ID for CloudWatch"
  value       = aws_kms_key.cloudwatch.key_id
}

output "cloudwatch_kms_key_arn" {
  description = "KMS key ARN for CloudWatch"
  value       = aws_kms_key.cloudwatch.arn
}

output "s3_kms_key_id" {
  description = "KMS key ID for S3"
  value       = aws_kms_key.s3.key_id
}

output "s3_kms_key_arn" {
  description = "KMS key ARN for S3"
  value       = aws_kms_key.s3.arn
}

output "ecs_kms_key_id" {
  description = "KMS key ID for ECS"
  value       = aws_kms_key.ecs.key_id
}

output "ecs_kms_key_arn" {
  description = "KMS key ARN for ECS"
  value       = aws_kms_key.ecs.arn
}
