variable "environment" {
  description = "Environment name"
  type        = string
}

variable "alb_arn" {
  description = "ALB ARN to associate WAF with"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for log encryption"
  type        = string
}

variable "rate_limit" {
  description = "Rate limit for requests per 5 minutes"
  type        = number
  default     = 2000
}

variable "allowed_countries" {
  description = "List of allowed country codes (ISO 3166-1 alpha-2). Empty list means all countries allowed."
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
