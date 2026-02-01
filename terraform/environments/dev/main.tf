# Main Terraform configuration for dev environment
# This ties all modules together

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "gcc-terraform-state-ap-southeast-1"
    key            = "dev/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "gcc-secure-foundation"
      ManagedBy   = "Terraform"
      Compliance  = "GCC"
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  cluster_name = "${var.environment}-eks-cluster"
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# KMS Module
module "kms" {
  source = "../../modules/kms"

  environment    = var.environment
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = var.aws_region
  tags           = local.common_tags
}

# CloudWatch Module (create log groups first)
module "cloudwatch" {
  source = "../../modules/cloudwatch"

  environment  = var.environment
  cluster_name = local.cluster_name
  kms_key_arn  = module.kms.cloudwatch_kms_key_arn
  aws_region   = var.aws_region
  tags         = local.common_tags
}

# IAM Module
module "iam" {
  source = "../../modules/iam"

  environment = var.environment
  kms_key_arn = module.kms.cloudwatch_kms_key_arn
  github_repo = var.github_repo
  tags        = local.common_tags
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  environment                   = var.environment
  vpc_cidr                      = var.vpc_cidr
  availability_zones            = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnet_cidrs           = var.public_subnet_cidrs
  private_subnet_cidrs          = var.private_subnet_cidrs
  flow_log_role_arn             = module.iam.vpc_flow_logs_role_arn
  flow_log_cloudwatch_group_arn = module.cloudwatch.vpc_flow_log_group_arn
  tags                          = local.common_tags
}

# Security Groups Module
module "security_groups" {
  source = "../../modules/security-groups"

  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = module.vpc.vpc_cidr
  cluster_name = local.cluster_name
  tags         = local.common_tags
}

# ECR Module
module "ecr" {
  source = "../../modules/ecr"

  environment        = var.environment
  repository_name    = var.app_name
  kms_key_arn        = module.kms.ecr_kms_key_arn
  allowed_principals = [data.aws_caller_identity.current.arn]
  tags               = local.common_tags
}

# EKS Module
module "eks" {
  source = "../../modules/eks"

  environment               = var.environment
  cluster_version           = var.eks_cluster_version
  cluster_role_arn          = module.iam.eks_cluster_role_arn
  node_role_arn             = module.iam.eks_node_role_arn
  private_subnet_ids        = module.vpc.private_subnet_ids
  public_subnet_ids         = module.vpc.public_subnet_ids
  cluster_security_group_id = module.security_groups.eks_cluster_sg_id
  kms_key_arn               = module.kms.ecs_kms_key_arn
  ebs_kms_key_arn           = module.kms.ecs_kms_key_arn
  cluster_log_group_name    = module.cloudwatch.eks_cluster_log_group_name
  desired_nodes             = var.desired_nodes
  min_nodes                 = var.min_nodes
  max_nodes                 = var.max_nodes
  instance_types            = var.instance_types
  tags                      = local.common_tags
}

# ALB Module (Optional - can use AWS Load Balancer Controller instead)
# Uncomment if you want a standalone ALB
# module "alb" {
#   source = "../../modules/alb"
#
#   environment           = var.environment
#   vpc_id                = module.vpc.vpc_id
#   subnet_ids            = module.vpc.public_subnet_ids
#   security_group_id     = module.security_groups.alb_sg_id
#   certificate_arn       = var.acm_certificate_arn
#   access_logs_bucket    = var.alb_logs_bucket
#   tags                  = local.common_tags
# }

# WAF Module (Optional - for ALB)
# module "waf" {
#   source = "../../modules/waf"
#
#   environment   = var.environment
#   alb_arn       = module.alb.alb_arn
#   kms_key_arn   = module.kms.cloudwatch_kms_key_arn
#   tags          = local.common_tags
# }
# Trigger pipeline
