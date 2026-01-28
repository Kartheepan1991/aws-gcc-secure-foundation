output "web_acl_id" {
  description = "WAF Web ACL ID"
  value       = aws_wafv2_web_acl.main.id
}

output "web_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = aws_wafv2_web_acl.main.arn
}

output "log_group_name" {
  description = "WAF CloudWatch log group name"
  value       = aws_cloudwatch_log_group.waf.name
}

output "log_group_arn" {
  description = "WAF CloudWatch log group ARN"
  value       = aws_cloudwatch_log_group.waf.arn
}
