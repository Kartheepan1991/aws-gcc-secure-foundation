output "eks_cluster_log_group_name" {
  description = "EKS cluster log group name"
  value       = aws_cloudwatch_log_group.eks_cluster.name
}

output "eks_cluster_log_group_arn" {
  description = "EKS cluster log group ARN"
  value       = aws_cloudwatch_log_group.eks_cluster.arn
}

output "application_log_group_name" {
  description = "Application log group name"
  value       = aws_cloudwatch_log_group.application.name
}

output "application_log_group_arn" {
  description = "Application log group ARN"
  value       = aws_cloudwatch_log_group.application.arn
}

output "vpc_flow_log_group_name" {
  description = "VPC flow log group name"
  value       = aws_cloudwatch_log_group.vpc_flow_logs.name
}

output "vpc_flow_log_group_arn" {
  description = "VPC flow log group ARN"
  value       = aws_cloudwatch_log_group.vpc_flow_logs.arn
}

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}
