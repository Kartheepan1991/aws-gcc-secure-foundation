variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for log encryption"
  type        = string
}

variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 30
}

variable "alarm_sns_topic_arns" {
  description = "SNS topic ARNs for alarm notifications"
  type        = list(string)
  default     = []
}

variable "target_group_arn" {
  description = "ALB target group ARN"
  type        = string
  default     = ""
}

variable "load_balancer_arn_suffix" {
  description = "ALB ARN suffix for metrics"
  type        = string
  default     = ""
}

variable "node_group_names" {
  description = "List of EKS node group names"
  type        = list(string)
  default     = []
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
