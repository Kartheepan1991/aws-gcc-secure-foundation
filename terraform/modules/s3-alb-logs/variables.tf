variable "environment" {
  description = "Environment name"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 90
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
