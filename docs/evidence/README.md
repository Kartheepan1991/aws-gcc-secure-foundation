# Evidence Collection Instructions

## Screenshots Required

### 1. EKS Cluster Screenshots
**Save to**: `docs/evidence/cluster/`

- [x] `01-eks-cluster-active.png` - EKS cluster overview showing Active status
- [ ] `02-eks-cluster-compute.png` - Compute tab showing node groups
- [ ] `03-eks-cluster-networking.png` - Networking configuration
- [ ] `04-eks-cluster-addons.png` - Add-ons installed (VPC-CNI, kube-proxy, CoreDNS)

### 2. Command Line Outputs
**Save to**: `docs/evidence/cli/`

```bash
# Get nodes
kubectl get nodes -o wide > docs/evidence/cli/kubectl-get-nodes.txt

# Get pods
kubectl get pods -A -o wide > docs/evidence/cli/kubectl-get-pods.txt

# Get services
kubectl get svc -A > docs/evidence/cli/kubectl-get-services.txt

# Describe cluster
aws eks describe-cluster --name dev-eks-cluster --region ap-southeast-1 > docs/evidence/cli/eks-describe-cluster.json
```

### 3. Application Screenshots
**Save to**: `docs/evidence/application/`

- [ ] `01-app-deployed.png` - kubectl get deployment output
- [ ] `02-app-running-pods.png` - Pod status showing Running
- [ ] `03-app-service-endpoint.png` - Service details with endpoint
- [ ] `04-app-health-check.png` - HTTP response from application

### 4. CI/CD Pipeline Screenshots
**Save to**: `docs/evidence/pipeline/`

- [ ] `01-github-actions-overview.png` - All workflow runs
- [ ] `02-pipeline-success.png` - Successful workflow execution
- [ ] `03-terraform-apply.png` - Terraform apply output
- [ ] `04-docker-build.png` - Docker build and push success
- [ ] `05-deployment-complete.png` - Application deployment success

### 5. Security & Monitoring
**Save to**: `docs/evidence/security/`

- [ ] `01-trivy-scan-results.png` - Security scan results
- [ ] `02-cloudwatch-logs.png` - CloudWatch log groups
- [ ] `03-ecr-repository.png` - ECR repository with image
- [ ] `04-iam-roles.png` - IAM roles for EKS

### 6. Infrastructure Details
**Save to**: `docs/evidence/infrastructure/`

- [ ] `01-vpc-overview.png` - VPC configuration
- [ ] `02-subnets.png` - Public/private subnet details
- [ ] `03-security-groups.png` - Security group rules
- [ ] `04-nat-gateway.png` - NAT Gateway for private subnets

---

## Quick Evidence Collection Script

```bash
#!/bin/bash
# Run this after deployment completes

EVIDENCE_DIR="docs/evidence/cli"
mkdir -p "$EVIDENCE_DIR"

echo "Collecting evidence..."

# Cluster info
kubectl cluster-info > "$EVIDENCE_DIR/cluster-info.txt"

# Nodes
kubectl get nodes -o wide > "$EVIDENCE_DIR/nodes.txt"
kubectl describe nodes > "$EVIDENCE_DIR/nodes-describe.txt"

# Pods
kubectl get pods -A -o wide > "$EVIDENCE_DIR/pods.txt"

# Services
kubectl get svc -A > "$EVIDENCE_DIR/services.txt"

# Deployments
kubectl get deployments -A > "$EVIDENCE_DIR/deployments.txt"

# ConfigMaps
kubectl get configmaps -A > "$EVIDENCE_DIR/configmaps.txt"

# EKS details
aws eks describe-cluster --name dev-eks-cluster --region ap-southeast-1 > "$EVIDENCE_DIR/eks-cluster.json"

# Node group
aws eks describe-nodegroup --cluster-name dev-eks-cluster --nodegroup-name dev-node-group --region ap-southeast-1 > "$EVIDENCE_DIR/eks-nodegroup.json"

# ECR images
aws ecr describe-images --repository-name gcc-app --region ap-southeast-1 > "$EVIDENCE_DIR/ecr-images.json"

echo "Evidence collection complete! Files saved to $EVIDENCE_DIR"
```

---

## To Save Your Current Screenshot

1. **Right-click** on the screenshot image above (AWS EKS Console)
2. **Save As**: `01-eks-cluster-active.png`
3. **Move to**: `/home/kartheepan/my-projects/aws-gcc-secure-foundation/docs/evidence/cluster/01-eks-cluster-active.png`

Or use this command:
```bash
# After saving screenshot to Downloads folder
mv ~/Downloads/01-eks-cluster-active.png \
   /home/kartheepan/my-projects/aws-gcc-secure-foundation/docs/evidence/cluster/
```

Then commit to repository:
```bash
cd /home/kartheepan/my-projects/aws-gcc-secure-foundation
git add docs/evidence/
git commit -m "Add deployment evidence: EKS cluster Active screenshot"
git push origin feature/gcc-infrastructure
```
