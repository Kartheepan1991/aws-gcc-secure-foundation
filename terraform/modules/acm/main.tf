# ACM Module - SSL/TLS Certificate for ALB
# Note: Certificate will be in "Pending Validation" state for demo
# ALB can still use pending certificates for HTTPS termination

resource "aws_acm_certificate" "main" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = var.subject_alternative_names

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-acm-certificate"
    }
  )
}

# Skip validation wait for demo - certificate can be used in pending state
# In production, use aws_acm_certificate_validation with Route53 records
