# AWS GCC Secure Foundation

Production-ready AWS infrastructure for Singapore Government Cloud Computing (GCC) workloads with EKS, implementing security best practices and compliance requirements.

##  Architecture

- **Compute**: Amazon EKS 1.28 with managed node groups
- **Networking**: Multi-AZ VPC with public/private subnets, NAT Gateway
- **Security**: KMS encryption, WAF, Security Groups with least privilege
- **Monitoring**: CloudWatch logs, metrics, alarms
- **CI/CD**: GitHub Actions with security scanning and policy gates
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

- AWS Account (Singapore region recommended)
- Terraform >= 1.5
- kubectl
- AWS CLI configured with credentials
- Docker

### Deployment Workflow

#### **Step 1: Setup Terraform Backend**

```bash
# Create S3 bucket + DynamoDB table for Terraform state
./scripts/setup-backend.sh
```

#### **Step 2: Deploy Infrastructure (Manual)**

```bash
cd terraform/environments/dev

# Configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your AWS account details

# Deploy infrastructure
terraform init
terraform validate
terraform plan
terraform apply
```

**What gets created:**
- VPC with 2 AZs (public/private subnets)
- EKS cluster v1.28
- ECR repository with encryption
- CloudWatch log groups
- KMS keys for encryption
- Security groups
- IAM roles

#### **Step 3: Application Deployment (GitHub Actions)**

```bash
# Configure kubectl
aws eks update-kubeconfig --region ap-southeast-1 --name dev-eks-cluster

# Configure GitHub Secrets
# Add to repository: Settings → Secrets and variables → Actions
#   AWS_ROLE_ARN (if using OIDC) or
#   AWS_ACCESS_KEY_ID + AWS_SECRET_ACCESS_KEY

# Push code to trigger CI/CD
git add .
git commit -m "Deploy application"
git push origin main
```

**GitHub Actions will:**
- Run security scans (Trivy)
- Build and test application
- Build Docker image
- Push to ECR
- Deploy to EKS

#### **Alternative: Manual App Deployment**

```bash
# Build and push Docker image
cd app
docker build -t gcc-app:latest .

ECR_URL=$(terraform -chdir=../terraform/environments/dev output -raw ecr_repository_url)
aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin $ECR_URL

docker tag gcc-app:latest $ECR_URL:latest
docker push $ECR_URL:latest

# Deploy to EKS
kubectl apply -f k8s/
```

### Cleanup

```bash
# Delete Kubernetes resources
kubectl delete -f app/k8s/

# Destroy infrastructure
cd terraform/environments/dev
terraform destroy

# Optional: Delete S3 backend bucket
aws s3 rb s3://gcc-terraform-state-ap-southeast-1 --force
aws dynamodb delete-table --table-name terraform-state-lock
```

##  Project Structure

```
├── terraform/modules/     # Reusable infrastructure modules
├── app/                   # Sample microservice
├── .github/workflows/     # CI/CD pipelines
├── scripts/              # Automation scripts
└── docs/                 # Documentation
```

##  Security & Compliance

- KMS encryption for all data at rest
- TLS 1.3 on ALB
- Container security contexts
- Image vulnerability scanning
- WAF protection

##  Monitoring

CloudWatch alarms for:
- EKS node utilization
- Pod failures
- ALB errors
- Failed authentication

---

**Technical Assessment**: Singapore GCC Cloud DevOps Role
