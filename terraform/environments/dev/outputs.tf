# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

# EKS Outputs
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = module.eks.cluster_security_group_id
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

# ECR Output
output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

# KMS Outputs
output "kms_key_ids" {
  description = "KMS key IDs"
  value = {
    ecr        = module.kms.ecr_kms_key_id
    ecs        = module.kms.ecs_kms_key_id
    cloudwatch = module.kms.cloudwatch_kms_key_id
  }
}

# CloudWatch Outputs
output "cloudwatch_log_groups" {
  description = "CloudWatch log group names"
  value = {
    vpc_flow_logs = module.cloudwatch.vpc_flow_log_group_name
    eks_cluster   = module.cloudwatch.eks_cluster_log_group_name
    application   = module.cloudwatch.app_log_group_name
  }
}

# IAM Outputs
output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions"
  value       = module.iam.github_actions_role_arn
}

# Security Group Outputs
output "security_groups" {
  description = "Security group IDs"
  value = {
    eks_cluster = module.security_groups.eks_cluster_sg_id
    eks_nodes   = module.security_groups.eks_nodes_sg_id
    alb         = module.security_groups.alb_sg_id
  }
}

# Quick Start Commands
output "deployment_commands" {
  description = "Commands to deploy the application"
  value       = <<-EOT
    # 1. Configure kubectl
    ${module.eks.cluster_name != "" ? "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}" : "N/A"}
    
    # 2. Verify cluster access
    kubectl get nodes
    
    # 3. Deploy application
    kubectl apply -f ../../app/k8s/
    
    # 4. Check deployment status
    kubectl get pods -n default
    kubectl get svc -n default
  EOT
}
