# ACM Module - Reference existing manually-created certificate
# Note: Certificate created manually outside Terraform for demo
# Using hardcoded ARN as certificate is in FAILED/PENDING state

# Certificate ARN (manually created)
locals {
  certificate_arn = "arn:aws:acm:ap-southeast-1:478286003472:certificate/fcd0102f-85ad-41d9-a126-3070d67a099a"
}
