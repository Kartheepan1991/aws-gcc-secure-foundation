variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

# Note: domain_name and subject_alternative_names removed
# Certificate is referenced by domain pattern *.gcc-demo.local
