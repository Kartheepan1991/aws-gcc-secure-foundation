# Assignment 1 - Deliverables Evidence

## Purpose
This document provides a comprehensive mapping of assignment requirements to implemented solutions, including evidence locations and verification procedures.

---

## 1. Infrastructure as Code (IaC) - Terraform

### Requirement
Deploy AWS infrastructure using Terraform following GCC best practices.

### Evidence Location
- **Code**: `terraform/` directory
  - `terraform/modules/` - Reusable modules (VPC, EKS, IAM, KMS, Security Groups, etc.)
  - `terraform/environments/dev/` - Environment-specific configuration
- **State Management**: S3 bucket `gcc-terraform-state-ap-southeast-1` with DynamoDB locking
- **Artifacts**: 
  - Terraform plan output (generated during CI/CD)
  - `terraform/environments/dev/terraform.tfvars.example` - Configuration template

### Key Features Demonstrated
✅ Multi-AZ VPC with public/private subnets  
✅ EKS cluster v1.33 with managed node groups  
✅ KMS encryption for secrets, EBS volumes, ECR  
✅ CloudWatch logging and monitoring  
✅ IAM roles with least privilege  
✅ Security groups with restricted access  
✅ VPC Flow Logs for network monitoring  
✅ Modular, reusable code structure  

### Screenshots to Capture
- [ ] Terraform plan output from GitHub Actions
- [ ] AWS Console: EKS cluster details
- [ ] AWS Console: VPC with subnets and route tables
- [ ] AWS Console: S3 backend bucket
- [ ] AWS Console: KMS keys list

---

## 2. CI/CD Pipeline - GitHub Actions

### Requirement
Automated deployment pipeline with security gates and approval workflows.

### Evidence Location
- **Code**: `.github/workflows/deploy.yml`
- **Pipeline URL**: https://github.com/Kartheepan1991/aws-gcc-secure-foundation/actions
- **Artifacts Generated**:
  - Trivy security scan reports
  - npm audit vulnerability reports
  - Docker image scan results
  - Terraform plan outputs
  - Deployment evidence bundle

### Pipeline Stages
1. **Security Scanning**
   - Trivy filesystem scan
   - npm dependency audit
   - Results uploaded as artifacts

2. **Build & Test**
   - Node.js application build
   - Jest unit tests
   - Code coverage reports

3. **Terraform Validation**
   - Format check
   - Syntax validation
   - tflint static analysis
   - Checkov policy-as-code scanning

4. **Terraform Plan**
   - Infrastructure change preview
   - Plan artifact saved
   - PR comment with plan output (for pull requests)

5. **Manual Approval Gate**
   - Required for production deployments
   - Demonstrates governance controls
   - GitHub Environment protection rule

6. **Terraform Apply**
   - Automated infrastructure deployment
   - State saved to S3 backend
   - Outputs captured for downstream jobs

7. **Docker Build & Scan**
   - Multi-stage Dockerfile build
   - Trivy container image scan
   - Image saved as artifact

8. **ECR Push**
   - Authenticate to AWS ECR
   - Tag and push container image
   - Latest + git SHA tags

9. **EKS Deployment**
   - kubectl configured via AWS CLI
   - Kubernetes manifests applied
   - Deployment status verified

10. **Evidence Generation**
    - Compliance report generated
    - All artifacts bundled
    - Available for download

### Screenshots to Capture
- [ ] GitHub Actions workflow overview (all 10 stages)
- [ ] Security scan results (Trivy, npm audit)
- [ ] Manual approval gate in action
- [ ] Terraform plan output in workflow
- [ ] Successful deployment to EKS
- [ ] Artifacts download page
- [ ] Checkov policy scan results

---

## 3. Containerized Application

### Requirement
Dockerized Node.js application deployed to EKS.

### Evidence Location
- **Code**: 
  - `app/Dockerfile` - Multi-stage build
  - `app/server.js` - Node.js Express application
  - `app/server.test.js` - Jest unit tests
- **Container Registry**: AWS ECR `dev/gcc-app`
- **Kubernetes Manifests**: `app/deployment.yaml`, `app/service.yaml`

### Application Features
✅ Health check endpoint (`/health`)  
✅ Express.js web server  
✅ Multi-stage Docker build (smaller image size)  
✅ Non-root user execution  
✅ Environment variable configuration  
✅ Unit test coverage  

### Screenshots to Capture
- [ ] AWS ECR repository with images
- [ ] Docker image scan results
- [ ] kubectl get pods (running pods)
- [ ] kubectl get svc (LoadBalancer service)
- [ ] Application health check response (curl or browser)
- [ ] kubectl describe deployment

---

## 4. GCC Compliance & Security

### Requirement
Implement security best practices aligned with Government Cloud Computing (GCC) standards.

### Evidence Location
- **Encryption**: 
  - KMS module: `terraform/modules/kms/`
  - EBS encryption in launch template
  - ECR encryption at rest
  - CloudWatch Logs encryption
- **Access Controls**:
  - IAM module: `terraform/modules/iam/`
  - Security groups: `terraform/modules/security-groups/`
  - Network segmentation (public/private subnets)
- **Logging & Monitoring**:
  - CloudWatch module: `terraform/modules/cloudwatch/`
  - EKS control plane logs (all 5 types enabled)
  - VPC Flow Logs
  - Application logs

### Security Controls Implemented
✅ **Encryption at Rest**
- EKS secrets encrypted with KMS
- EBS volumes encrypted
- ECR images encrypted
- CloudWatch Logs encrypted

✅ **Network Security**
- Private subnets for EKS nodes
- NAT Gateways for outbound traffic
- Security groups with least privilege
- VPC Flow Logs enabled

✅ **Access Management**
- IAM roles with assume role policies
- Service-specific IAM policies
- No hardcoded credentials
- AWS Secrets Manager integration ready

✅ **Audit & Compliance**
- All EKS control plane logs enabled
- CloudWatch metric filters for security events
- Trivy security scanning in CI/CD
- Checkov policy-as-code validation

✅ **High Availability**
- Multi-AZ deployment (2 AZs)
- Auto-scaling node groups
- Load balancer for application access

### Screenshots to Capture
- [ ] KMS keys with rotation enabled
- [ ] CloudWatch Log Groups list
- [ ] VPC Flow Logs enabled
- [ ] EKS cluster encryption configuration
- [ ] Security group rules (restrictive)
- [ ] CloudWatch dashboard (if created)
- [ ] IAM roles and policies
- [ ] Trivy scan showing no critical vulnerabilities

---

## 5. Documentation

### Requirement
Comprehensive documentation for setup, deployment, and operations.

### Evidence Location
- **README.md** - Project overview and current status
- **QUICKSTART.md** - Step-by-step setup guide
- **ASSIGNMENT_DELIVERABLES.md** - This document
- **terraform/modules/*/README.md** - Module-specific documentation
- **Code Comments** - Inline documentation throughout

### Documentation Coverage
✅ Architecture overview  
✅ Prerequisites and setup  
✅ CI/CD pipeline explanation  
✅ Deployment instructions  
✅ Troubleshooting guide  
✅ Cost optimization notes  
✅ Security considerations  

---

## Evidence Collection Checklist

### From GitHub Actions
- [ ] Download workflow run artifacts (use "Download artifacts" button)
- [ ] Screenshot of successful pipeline execution
- [ ] Screenshot of manual approval gate
- [ ] Screenshot of Terraform plan output
- [ ] Screenshot of security scan results (Trivy, Checkov)

### From AWS Console
- [ ] EKS cluster details (version, status, encryption)
- [ ] VPC and networking (subnets, route tables, NAT gateways)
- [ ] ECR repository with container images
- [ ] KMS keys configuration
- [ ] CloudWatch Log Groups
- [ ] S3 backend bucket for Terraform state
- [ ] IAM roles and policies

### From Kubernetes
```bash
# Connect to cluster
aws eks update-kubeconfig --region ap-southeast-1 --name dev-eks-cluster

# Capture these outputs
kubectl get nodes -o wide
kubectl get pods -n default
kubectl get svc -n default
kubectl get deployments -n default
kubectl describe pod <pod-name>
```

### From Application
- [ ] Health check endpoint response: `curl http://<LoadBalancer-URL>/health`
- [ ] Application logs: `kubectl logs <pod-name>`

---

## Presentation Structure

### 1. Introduction (2 minutes)
- Assignment objectives
- Architecture overview diagram
- Technology stack

### 2. Infrastructure as Code (5 minutes)
- Terraform modules walkthrough
- Key configurations (VPC, EKS, security)
- State management approach

### 3. CI/CD Pipeline (5 minutes)
- GitHub Actions workflow demonstration
- Security scanning integration
- Manual approval gate
- Automated deployment process

### 4. Security & Compliance (3 minutes)
- GCC alignment
- Encryption implementation
- Network security
- Access controls
- Audit logging

### 5. Live Demonstration (3 minutes)
- Trigger pipeline manually
- Show approval workflow
- Verify deployment
- Access running application

### 6. Q&A (2 minutes)

---

## Key Metrics to Report

### Infrastructure
- **EKS Version**: 1.33
- **Node Type**: t3.micro (cost-optimized for free tier)
- **Availability Zones**: 2
- **Encryption**: KMS for EKS secrets, EBS, ECR, CloudWatch

### Pipeline
- **Total Stages**: 10
- **Security Scans**: 3 (Trivy filesystem, Trivy image, Checkov)
- **Approval Gates**: 1 (manual approval before apply)
- **Average Deployment Time**: ~20-25 minutes (EKS cluster creation)

### Security
- **IAM Roles**: 3 (cluster, nodes, VPC flow logs)
- **Security Groups**: 4 (cluster, nodes, ALB, VPC endpoints)
- **Log Groups**: 3 (EKS cluster, application, VPC flow logs)
- **KMS Keys**: 4 (EKS, ECR, ECS, CloudWatch)

---

## Cost Considerations (Free Tier)

### Current Configuration
- **EKS Cluster**: Free for 12 months (first cluster)
- **EC2 Instances**: t3.micro (1 node) - within free tier limits
- **NAT Gateway**: $0.045/hour (~$32/month) - **Main cost driver**
- **EBS Volumes**: 20GB gp3 per node - within free tier
- **Data Transfer**: Minimal for testing

### Cost Optimization Applied
✅ Reduced nodes from 3 to 1-2  
✅ Changed instance type from t3.medium to t3.micro  
✅ Single NAT Gateway instead of 2 (dev environment)  
✅ Enabled EBS encryption (free with KMS)  
✅ 30-day log retention (reduced from default)  

**Estimated Monthly Cost**: $35-40 (mostly NAT Gateway)

---

## Next Steps After Pipeline Completion

1. **Collect Evidence**
   - Download all GitHub Actions artifacts
   - Take AWS Console screenshots
   - Capture kubectl outputs

2. **Test Application**
   - Access application via LoadBalancer URL
   - Verify health endpoint
   - Check logs in CloudWatch

3. **Prepare Presentation**
   - Create architecture diagram
   - Prepare demo script
   - Test live demonstration flow

4. **Cleanup (After Submission)**
   ```bash
   cd terraform/environments/dev
   terraform destroy -auto-approve
   ```

---

## References

- **Repository**: https://github.com/Kartheepan1991/aws-gcc-secure-foundation
- **Branch**: feature/gcc-infrastructure
- **Pipeline**: https://github.com/Kartheepan1991/aws-gcc-secure-foundation/actions
- **AWS Region**: ap-southeast-1 (Singapore)
- **Account ID**: 478286003472
