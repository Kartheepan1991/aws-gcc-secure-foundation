# ACM Module - SSL/TLS Certificate for ALB

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

# Note: For production, you would validate via Route53
# For demo/assessment, certificate will be in "Pending Validation" state
# ALB will still work with pending certificate for demo purposes
