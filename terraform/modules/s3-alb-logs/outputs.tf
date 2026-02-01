output "bucket_name" {
  description = "ALB logs bucket name"
  value       = aws_s3_bucket.alb_logs.id
}

output "bucket_arn" {
  description = "ALB logs bucket ARN"
  value       = aws_s3_bucket.alb_logs.arn
}
