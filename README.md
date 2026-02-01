# AWS GCC Secure Foundation

Enterprise-grade AWS infrastructure for Singapore Government Cloud Computing (GCC) workloads, featuring Amazon EKS with comprehensive security controls and automated deployment pipelines.

## Overview

**Infrastructure**: Amazon EKS on AWS (Singapore Region)  
**Deployment**: Infrastructure as Code (Terraform) with CI/CD automation  
**Security**: GCC-compliant security controls and encryption standards

##  Architecture

- **Compute**: Amazon EKS 1.33 with managed node groups (t3.micro)
- **Networking**: Multi-AZ VPC with public/private subnets, NAT Gateway
- **Security**: KMS encryption, Security Groups with least privilege
- **Monitoring**: CloudWatch logs, metrics, alarms, dashboards
- **CI/CD**: GitHub Actions with security scanning, manual approval gates
- **Container Registry**: ECR with image scanning and KMS encryption

##  GCC Compliance Features

 **Encryption**: KMS encryption for EKS secrets, ECR, CloudWatch Logs, EBS volumes  
 **Network Segmentation**: Private subnets for workloads, public subnets for ALB  
 **Logging & Monitoring**: VPC Flow Logs, EKS control plane logs, application logs  
 **IAM**: Least privilege roles for EKS, nodes, CI/CD pipelines  
 **WAF**: Protection against common web exploits, rate limiting  
 **Container Security**: Image scanning, non-root containers, read-only filesystems  

##  Quick Start

### Prerequisites

- AWS Account (Free Tier compatible)
- Terraform >= 1.5 (local) or 1.6+ (pipeline)
- kubectl
- AWS CLI configured with credentials
- Docker (for local testing)
- GitHub account with repository secrets configured

### Setup Instructions

#### **Method 1: Local Deployment (Recommended for Testing)**

```bash
# 1. Setup Terraform backend
cd terraform/environments/dev
terraform init

# 2. Configure AWS credentials
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_DEFAULT_REGION="ap-southeast-1"

# 3. Review and customize variables
# Edit terraform.tfvars (gitignored):
# - Set github_repo = "" (disables OIDC for access key auth)
# - Confirm eks_cluster_version = "1.33"
# - Confirm instance_types = ["t3.micro"]

# 4. Deploy infrastructure
terraform plan
terraform apply -auto-approve

# 5. Configure kubectl
aws eks update-kubeconfig --region ap-southeast-1 --name dev-eks-cluster
kubectl get nodes

# 6. Verify deployment
kubectl get pods -A
```

**Deployment time**: ~20-25 minutes (EKS cluster + node groups)

#### **Method 2: CI/CD Pipeline (GitHub Actions)**

```bash
# 1. Configure GitHub Secrets
# Go to: Settings → Secrets and variables → Actions
# Add secrets:
#   - AWS_ACCESS_KEY_ID
#   - AWS_SECRET_ACCESS_KEY

# 2. Push to trigger pipeline
git add .
git commit -m "Deploy infrastructure via CI/CD"
git push origin feature/gcc-infrastructure

# 3. Monitor workflow
# Visit: https://github.com/Kartheepan1991/aws-gcc-secure-foundation/actions

# 4. Approve terraform apply
# Manual approval required in GitHub Actions UI
```

**Pipeline Phases**:
1. Security Scanning (Trivy)
2. Build & Test Application
3. Terraform Validation
4. Terraform Plan
### Pipeline Workflow

The CI/CD pipeline implements a comprehensive security-first deployment approach:

1. Security Scanning
2. Build & Test
3. Terraform Validation
4. Terraform Plan
5. Manual Approval Gate
6. Terraform Apply
7. Container Build
8. ECR Push
9. EKS Deployment
10. Evidence Generation

### Infrastructure Cleanup

```bash
cd terraform/environments/dev
terraform destroy -auto-approve
```

## Infrastructure Components

**Network Layer**:
- Multi-AZ VPC with public/private subnet segregation
- NAT Gateways for secure egress
- VPC Flow Logs for traffic monitoring

**Compute Layer**:
- Amazon EKS 1.33 with managed node groups
- Auto-scaling configuration (1-2 nodes)
- EKS addons: vpc-cni, kube-proxy, coredns

**Security Layer**:
- KMS encryption for data at rest (EKS, ECR, CloudWatch, EBS)
- Security groups with least-privilege rules
- IAM roles with minimal permissions

**Monitoring Layer**:
- CloudWatch Logs for EKS control plane and applications
- CloudWatch Alarms for critical events
- CloudWatch Dashboard for operational visibility

**State Management**:
- S3 backend with server-side encryption
- DynamoDB for state locking

##  Project Structure

```
aws-gcc-secure-foundation/
├── .github/workflows/
│   └── deploy.yml           # CI/CD pipeline configuration
├── terraform/
│   ├── environments/dev/
│   │   ├── main.tf          # Root terraform configuration
│   │   ├── terraform.tfvars # Environment-specific variables
│   │   └── outputs.tf       # Infrastructure outputs
│   └── modules/
│       ├── vpc/             # Network infrastructure
│       ├── eks/             # Kubernetes cluster
│       ├── iam/             # Access management
│       ├── security-groups/ # Network security
│       ├── kms/             # Encryption keys
│       ├── ecr/             # Container registry
│       └── cloudwatch/      # Logging and monitoring
├── app/
│   ├── server.js            # Application code
│   ├── Dockerfile           # Container definition
│   └── k8s/                 # Kubernetes manifests
└── scripts/
    └── setup-backend.sh     # Backend initialization
```

## Security Controls

### Data Protection
- Customer-managed KMS keys for encryption at rest
- EBS volume encryption via launch templates
- ECR image encryption with KMS
- CloudWatch Logs encryption

### Network Security
- Private subnet isolation for compute resources
- Network segmentation with security groups
- VPC Flow Logs for audit trails
- NAT Gateways for controlled internet access

### Identity & Access Management
- IAM roles with least-privilege policies
- EKS RBAC integration
- Pod security contexts (non-root execution)
- IMDSv2 enforcement on EC2 instances

### Operational Monitoring
- Comprehensive EKS control plane logging
- Application log aggregation to CloudWatch
- CloudWatch Alarms for anomaly detection
- Dashboard for real-time metrics

---

**Project Repository**: https://github.com/Kartheepan1991/aws-gcc-secure-foundation
