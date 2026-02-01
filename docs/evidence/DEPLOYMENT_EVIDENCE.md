# Assignment 1: Infrastructure Deployment Evidence

## Deployment Timeline

**Date**: February 1, 2026  
**Repository**: aws-gcc-secure-foundation  
**Branch**: feature/gcc-infrastructure  

---

## 1. EKS Cluster Deployment Success

### Cluster Information
- **Cluster Name**: dev-eks-cluster
- **Status**: ✅ Active
- **Kubernetes Version**: 1.33
- **Platform Version**: eks.27
- **Region**: ap-southeast-1 (Singapore)
- **Deployment Time**: 25 minutes
- **Created**: February 1, 2026

### Health Metrics
- **Cluster Health**: 0 issues (✅ Green)
- **Node Health**: 0 issues (✅ Green)
- **Capability Issues**: 0 (✅ Green)
- **Upgrade Insights**: 5 available

### Endpoints
- **API Server**: `https://8DCC85DC86D92CEF401C56CDA4806650.sk1.ap-southeast-1.eks.amazonaws.com`
- **OpenID Connect Provider**: `https://oidc.eks.ap-southeast-1.amazonaws.com/id/8DCC85DC86D92CEF401C56CDA4806650`

### IAM Configuration
- **Cluster Role ARN**: `arn:aws:iam::478286003472:role/dev-eks-cluster-role`
- **Account ID**: 478286003472

### Screenshots
**File**: `01-eks-cluster-active.png`  
**Location**: `docs/evidence/cluster/`  
**Description**: AWS Console showing EKS cluster in Active state with all health checks passing

---

## 2. Infrastructure Components Deployed

### Networking
- ✅ VPC with 2 availability zones
- ✅ Public and private subnets
- ✅ NAT Gateway for private subnet internet access
- ✅ Internet Gateway for public subnet
- ✅ VPC Flow Logs enabled

### Compute
- ✅ EKS Control Plane (version 1.33)
- ✅ Node Group with 1 t3.micro instance (free tier optimized)
- ✅ Auto-scaling configuration (min: 1, max: 2)

### Security
- ✅ IAM roles for EKS cluster and node groups
- ✅ Security groups with least-privilege access
- ✅ AWS-managed encryption for EBS volumes
- ✅ ECR with AES256 encryption
- ✅ CloudWatch Logs encryption

### Monitoring & Logging
- ✅ CloudWatch Log Groups for EKS, VPC, application
- ✅ CloudWatch Alarms for high CPU, pod failures
- ✅ Metric filters for security events

### Container Registry
- ✅ ECR repository: `gcc-app`
- ✅ Image scanning enabled
- ✅ Lifecycle policies configured

---

## 3. CI/CD Pipeline Execution

### Pipeline Phases Completed
1. ✅ Security Scanning (Trivy, npm audit)
2. ✅ Build & Test (npm test with coverage)
3. ✅ Terraform Validate
4. ✅ Terraform Plan (manual approval)
5. ✅ Terraform Apply (~49 resources created)
6. 🔄 Docker Build (in progress)
7. ⏳ Push to ECR
8. ⏳ Deploy to EKS
9. ⏳ Generate Evidence Report

### Commits
- **Latest**: `149343f` - Update CodeQL Action from v2 to v3
- **Previous**: `1c105d4` - Add package-lock.json for npm ci
- **Previous**: `be17561` - Fix CloudWatch log group lifecycle

---

## 4. Configuration Decisions

### Free Tier Optimization
- **Instance Type**: t3.micro (2 vCPU, 1GB RAM)
- **Node Count**: 1 desired, max 2
- **Rationale**: Cost optimization for development/testing

### Encryption Strategy
- **Approach**: AWS-managed encryption keys
- **Services**: EBS, ECR, CloudWatch Logs
- **Rationale**: Time-constrained deployment, KMS module preserved for future use
- **Note**: Customer-managed KMS module code exists in `terraform/modules/kms/`

### Version Selection
- **EKS Version**: 1.33 (latest stable)
- **Terraform**: 1.6.0 (pipeline), 1.12.2 (local)
- **Node.js**: 18.x
- **Platform**: eks.27

---

## 5. Evidence Artifacts

### Required for Submission
- [x] EKS cluster Active screenshot (AWS Console)
- [ ] kubectl get nodes output
- [ ] kubectl get pods output
- [ ] Application health check response
- [ ] Docker image in ECR
- [ ] CloudWatch logs screenshot
- [ ] GitHub Actions pipeline success
- [ ] Terraform state outputs
- [ ] Security scan results
- [ ] Test coverage report

### Artifact Locations
- **GitHub Actions**: https://github.com/Kartheepan1991/aws-gcc-secure-foundation/actions
- **AWS Console**: EKS cluster overview (this screenshot)
- **Local Evidence**: `docs/evidence/`

---

## Next Steps

1. ✅ EKS cluster deployed and healthy
2. 🔄 Wait for Docker build completion
3. ⏳ Application deployment to cluster
4. ⏳ Collect all evidence artifacts
5. ⏳ Prepare presentation slides
6. ⏳ Submit Assignment 1

---

**Status**: Infrastructure deployment successful, application deployment in progress  
**Overall Progress**: 60% complete
