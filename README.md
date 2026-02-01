# AWS GCC Secure Foundation

Production-ready AWS infrastructure for Singapore Government Cloud Computing (GCC) workloads with EKS, implementing security best practices and compliance requirements.

## 🚀 Current Status

**Branch**: `feature/gcc-infrastructure` (default)  
**Infrastructure**: Ready for deployment  
**CI/CD Pipeline**: Configured with approval gates  
**AWS Account**: 478286003472 (ap-southeast-1)

### Recent Updates
- ✅ Upgraded EKS to v1.33
- ✅ Optimized for AWS Free Tier (t3.small instances)
- ✅ Fixed terraform backend (S3 + DynamoDB state management)
- ✅ Configured GitHub Actions workflow with manual approval
- ✅ Resolved disk_size conflict in node group configuration
- ✅ Added terraform/** to workflow triggers

##  Architecture

- **Compute**: Amazon EKS 1.33 with managed node groups (t3.small)
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
# - Confirm instance_types = ["t3.small"]

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
5. **Manual Approval Gate** ⏸️
6. Terraform Apply (creates EKS)
7. Build Docker Image
8. Push to ECR
9. Deploy to EKS
10. Generate Evidence Report

### Cleanup

```bash
# Destroy all infrastructure
cd terraform/environments/dev
terraform destroy -auto-approve

# Cleanup takes ~10-15 minutes
# Deletes: EKS cluster, VPC, KMS keys, ECR, CloudWatch logs, IAM roles
```

## 📋 Infrastructure Resources

**Created by Terraform (58 resources)**:
- VPC with 2 AZs, 4 subnets (2 public, 2 private)
- EKS cluster v1.33 with OIDC provider
- EKS node group (1-2 t3.small instances)
- EKS addons: vpc-cni, kube-proxy, coredns
- 2 NAT Gateways + 2 Elastic IPs
- 4 KMS keys (EKS, ECR, CloudWatch, S3)
- ECR repository with lifecycle policy
- 3 CloudWatch log groups + 2 metric alarms
- CloudWatch dashboard
- VPC Flow Logs
- 5 Security Groups
- 7 IAM roles with policies

**Cost Optimization**:
- t3.small instances (free tier eligible)
- Single node group (min: 1, max: 2)
- 2 AZs only (reduced NAT Gateway costs)
- 20GB EBS volumes (gp3)

##  Project Structure

```
aws-gcc-secure-foundation/
├── .github/workflows/
│   └── deploy.yml           # 10-phase CI/CD pipeline with approval gates
├── terraform/
│   ├── environments/dev/
│   │   ├── main.tf          # Root module (S3 backend)
│   │   ├── terraform.tfvars # Environment variables (gitignored)
│   │   └── outputs.tf       # Cluster connection details
│   └── modules/
│       ├── vpc/             # Multi-AZ networking
│       ├── eks/             # EKS cluster + node groups
│       ├── iam/             # IAM roles (cluster, nodes, flow logs)
│       ├── security-groups/ # Network security rules
│       ├── kms/             # Encryption keys
│       ├── ecr/             # Container registry
│       └── cloudwatch/      # Logging and monitoring
├── app/
│   ├── server.js            # Sample Node.js microservice
│   ├── Dockerfile           # Multi-stage container build
│   └── k8s/                 # Kubernetes manifests
└── scripts/
    └── setup-backend.sh     # S3 + DynamoDB state backend

State Management:
├── S3: gcc-terraform-state-ap-southeast-1
└── DynamoDB: terraform-state-lock
```

## 🔧 Known Issues & Fixes

### Fixed Issues
✅ **Disk size conflict**: Removed `disk_size` from node_group (defined in launch_template)  
✅ **OIDC role error**: Set `TF_VAR_github_repo=""` in workflow to disable OIDC when using access keys  
✅ **KMS backend error**: Removed non-existent KMS key from S3 backend config  
✅ **Workflow triggers**: Added `terraform/**` to workflow path filters  
✅ **Manual trigger**: Added `workflow_dispatch` support for terraform-plan job

### Pending Items
- Test complete CI/CD pipeline end-to-end
- Verify manual approval gate workflow
- Deploy sample application to EKS
- Generate compliance evidence artifacts

##  Security & Compliance

### Encryption at Rest
- EKS secrets encrypted with customer-managed KMS key
- ECR images encrypted with KMS
- CloudWatch Logs encrypted with KMS
- EBS volumes encrypted with KMS (via launch template)
- S3 state bucket with server-side encryption

### Network Security
- Private subnets for EKS nodes (no direct internet access)
- Public subnets for load balancers only
- Security groups with least privilege rules
- VPC Flow Logs for network monitoring
- NAT Gateways for controlled egress

### Access Control
- IAM roles with minimal required permissions
- EKS RBAC enabled
- Pod security contexts (non-root, read-only filesystem)
- IMDSv2 enforced on EC2 instances

### Monitoring & Auditing
- EKS control plane logs (api, audit, authenticator, scheduler, controllerManager)
- Application logs to CloudWatch
- VPC Flow Logs
- CloudWatch alarms for pod failures and failed authentication
- CloudWatch dashboard for metrics visualization

##  Monitoring

**CloudWatch Alarms**:
- Pod restart threshold (>5 restarts in 5 minutes)
- Failed authentication attempts (>10 in 5 minutes)

**CloudWatch Dashboard**:
- ALB metrics (response time, request count, HTTP codes)
- EKS cluster metrics (CPU, memory, pod utilization)

**Log Groups**:
- `/aws/eks/dev-eks-cluster/cluster` - EKS control plane
- `/aws/eks/dev-eks-cluster/application` - Application logs
- `/aws/vpc/dev-flow-logs` - VPC network traffic

## 🎯 Tomorrow's Plan

1. **Commit & Push All Changes**
   ```bash
   git add .
   git commit -m "Complete infrastructure setup with all fixes"
   git push origin feature/gcc-infrastructure
   ```

2. **Test CI/CD Pipeline**
   - Monitor GitHub Actions workflow
   - Approve terraform apply step
   - Verify EKS cluster creation
   - Check application deployment

3. **Validate Deployment**
   ```bash
   kubectl get nodes
   kubectl get pods -A
   kubectl get svc
   ```

4. **Generate Evidence**
   - Download workflow artifacts
   - Capture screenshots
   - Document compliance controls

---

**Technical Assessment**: Singapore GCC Cloud DevOps Role  
**Repository**: [aws-gcc-secure-foundation](https://github.com/Kartheepan1991/aws-gcc-secure-foundation)  
**Branch**: `feature/gcc-infrastructure`
