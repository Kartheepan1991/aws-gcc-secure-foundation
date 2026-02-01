output "certificate_arn" {
  description = "ACM certificate ARN"
  value       = data.aws_acm_certificate.main.arn
}

output "certificate_id" {
  description = "ACM certificate ID"
  value       = data.aws_acm_certificate.main.id
}

output "domain_name" {
  description = "Domain name"
  value       = data.aws_acm_certificate.main.domain
}

output "validation_options" {
  description = "Certificate validation options"
  value       = []
  # Data source doesn't expose validation options
}
