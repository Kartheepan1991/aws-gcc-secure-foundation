variable "environment" {
  description = "Environment name"
  type        = string
}

variable "repository_name" {
  description = "ECR repository name"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for ECR encryption (optional)"
  type        = string
  default     = null
}

variable "allowed_principals" {
  description = "AWS principals allowed to access ECR"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
