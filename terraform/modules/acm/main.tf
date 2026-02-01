# ACM Module - Reference existing manually-created certificate
# Note: Certificate created manually outside Terraform for demo
# In production, manage this through Terraform with Route53 validation

# Use existing certificate by domain name
data "aws_acm_certificate" "main" {
  domain   = "*.gcc-demo.local"
  statuses = ["PENDING_VALIDATION", "ISSUED"]
  most_recent = true
}
