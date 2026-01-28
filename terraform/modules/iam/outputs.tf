output "eks_cluster_role_arn" {
  description = "EKS cluster role ARN"
  value       = aws_iam_role.eks_cluster.arn
}

output "eks_node_role_arn" {
  description = "EKS node role ARN"
  value       = aws_iam_role.eks_node.arn
}

output "cicd_role_arn" {
  description = "CI/CD role ARN"
  value       = var.github_repo != "" ? aws_iam_role.cicd[0].arn : ""
}

output "vpc_flow_logs_role_arn" {
  description = "VPC flow logs role ARN"
  value       = aws_iam_role.vpc_flow_logs.arn
}
