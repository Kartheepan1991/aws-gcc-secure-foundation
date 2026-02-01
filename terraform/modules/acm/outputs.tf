output "certificate_arn" {
  description = "ACM certificate ARN"
  value       = local.certificate_arn
}

output "certificate_id" {
  description = "ACM certificate ID"
  value       = split("/", local.certificate_arn)[1]
}

output "domain_name" {
  description = "Domain name"
  value       = "*.gcc-demo.local"
}

output "validation_options" {
  description = "Certificate validation options"
  value       = []
}
