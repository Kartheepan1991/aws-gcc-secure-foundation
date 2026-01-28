variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ALB"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for ALB"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
}

variable "access_logs_bucket" {
  description = "S3 bucket for ALB access logs"
  type        = string
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/health"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
