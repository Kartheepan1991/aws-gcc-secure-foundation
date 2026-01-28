#  Quick Start Guide - GCC Secure Foundation

## For Interview Assessment

This guide gets you from zero to deployed in ~45 minutes.

---

## Prerequisites (5 minutes)

```bash
# Check you have these installed
aws --version       # AWS CLI
terraform --version # Terraform >= 1.5
kubectl version     # kubectl
docker --version    # Docker

# Configure AWS (use your free tier account)
aws configure
# AWS Access Key ID: [YOUR_KEY]
# AWS Secret Access Key: [YOUR_SECRET]
# Default region: ap-southeast-1
# Default output format: json

# Verify AWS access
aws sts get-caller-identity
```

---

## Step 1: Configure Variables (2 minutes)

```bash
cd /home/kartheepan/my-projects/aws-gcc-secure-foundation/terraform/environments/dev

# Copy example to actual tfvars
cp terraform.tfvars.example terraform.tfvars

# Edit if needed (defaults are fine for assessment)
nano terraform.tfvars
```

---

## Step 2: Deploy Everything (30-40 minutes)

```bash
cd /home/kartheepan/my-projects/aws-gcc-secure-foundation

# Run the automated deployment script
./scripts/deploy.sh
```

The script will:
-  Setup S3 backend (1 min)
-  Initialize Terraform (1 min)
-  Create infrastructure plan (2 min)
- ⏸️  **PAUSE for your approval**
-  Deploy infrastructure (15 min) - EKS cluster takes time
-  Build Docker image (2 min)
-  Push to ECR (1 min)
-  Deploy to EKS (3 min)
-  Collect evidence (auto)

**Total Time:** ~30-40 minutes

---

## Step 3: Test & Collect Evidence (10 minutes)

### Get the application URL

```bash
# Get load balancer URL
kubectl get ingress gcc-app-ingress -n default

# Or use this one-liner
ALB_URL=$(kubectl get ingress gcc-app-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Application URL: http://$ALB_URL"
```

### Test endpoints

```bash
# Health check
curl http://$ALB_URL/health

# Main endpoint
curl http://$ALB_URL/

# API status
curl http://$ALB_URL/api/status
```

### Take screenshots

1. **AWS Console - EKS:**
   - Go to: https://ap-southeast-1.console.aws.amazon.com/eks/
   - Screenshot: Cluster "dev-eks-cluster" running

2. **AWS Console - VPC:**
   - Go to: VPC → Your VPCs
   - Screenshot: VPC with 2 AZs, public/private subnets

3. **AWS Console - KMS:**
   - Go to: KMS → Customer managed keys
   - Screenshot: Multiple KMS keys created

4. **AWS Console - CloudWatch:**
   - Go to: CloudWatch → Log groups
   - Screenshot: Log groups with 90 day retention

5. **Browser - Application:**
   - Open: http://ALB_URL
   - Screenshot: Application response

6. **Terminal - Kubectl:**
   ```bash
   kubectl get all -n default
   # Screenshot this output
   ```

### Check generated evidence

```bash
ls -la docs/evidence/
# Should contain:
# - 01-backend-setup.log
# - 02-terraform-init.log
# - 03-terraform-plan.log
# - 04-terraform-apply.log
# - 05-outputs.txt
# - 06-eks-nodes.txt
# - 07-kubectl-apply.log
# - 08-pods-status.txt
```

---

## Step 4: Cleanup (IMPORTANT!) (10 minutes)

**DO THIS AFTER collecting all evidence to avoid AWS charges!**

```bash
cd /home/kartheepan/my-projects/aws-gcc-secure-foundation

# Run cleanup script
./scripts/cleanup.sh

# Confirm when prompted:
# 1. Type "yes" to confirm evidence collected
# 2. Type "destroy" to confirm deletion
```

This will:
- Delete Kubernetes resources
- Destroy all Terraform infrastructure
- Remove S3 backend
- Clean up local state files

**Estimated cost if cleaned up within 2-3 hours:** $3-5

---

##  What You Get

### Files Created

```
aws-gcc-secure-foundation/
├── terraform/          # Complete IaC for AWS
│   ├── modules/       # 9 reusable modules
│   └── environments/  # DEV environment ready
├── app/               # Secure Node.js microservice
├── .github/           # CI/CD pipeline (GitHub Actions)
├── scripts/           # Automation scripts
└── docs/              # GCC compliance docs + evidence
```

### Compliance Coverage

 **A. Terraform Infrastructure**
- VPC across 2 AZs with public/private subnets
- Security groups with least privilege
- IAM roles for CI/CD and runtime
- CloudWatch with 90-day retention
- KMS encryption for everything
- S3 backend with DynamoDB locking
- All validations passing

 **B. Application Deployment**
- EKS cluster with managed nodes
- Sample Node.js microservice
- ALB with TLS termination
- Secure headers (Helmet.js)
- WAF with OWASP protection

 **C. CI/CD Pipeline**
- Complete GitHub Actions workflow
- Security scanning (Trivy, Checkov)
- Build → Test → Scan → Deploy
- Manual approval gates
- Artifact generation

 **D. GCC Compliance**
- Complete controls mapping
- SHIP-HATS integration guide
- Evidence collection automated

---

## 🎯 Assessment Submission

### Required Files

1. **Code Repository:**
   - GitHub repo (or ZIP file)
   - All Terraform modules
   - Application code
   - CI/CD pipeline
   - Documentation

2. **Evidence Package:**
   - `docs/evidence/` folder with logs
   - Screenshots (6 required)
   - `docs/GCC-COMPLIANCE-MAPPING.md`
   - `docs/ASSESSMENT-DELIVERABLES.md`

3. **Scan Reports:**
   - Download from GitHub Actions artifacts
   - Or run locally: `trivy fs .`

---

## 🆘 Troubleshooting

### Issue: Terraform backend error

```bash
# Delete and recreate backend
./scripts/setup-backend.sh
```

### Issue: EKS cluster not accessible

```bash
# Reconfigure kubectl
aws eks update-kubeconfig --region ap-southeast-1 --name dev-eks-cluster
```

### Issue: Pods not starting

```bash
# Check pod logs
kubectl logs -f deployment/gcc-app -n default

# Check events
kubectl get events -n default --sort-by='.lastTimestamp'
```

### Issue: Terraform apply fails

```bash
# Check your AWS quotas
aws service-quotas list-service-quotas --service-code eks

# Common issues:
# - VPC limit (default: 5)
# - EIP limit (default: 5)
# - EKS cluster limit (default: 10)
```

---

##  Cost Estimate

### Running Costs (per hour)

- EKS Control Plane: $0.10/hour ($72/month, prorated)
- EC2 t3.medium × 2: ~$0.08/hour
- NAT Gateway: ~$0.05/hour
- ALB: ~$0.03/hour
- **Total: ~$0.26/hour**

### One-Time Costs

- S3 storage: $0.01
- DynamoDB: Free tier
- CloudWatch Logs: Free tier (first 5GB)

### Assessment Budget

- 3 hours deployment + testing: ~$0.80
- **Total: < $1.00**

---

##  Success Checklist

Before cleanup:

- [ ] Infrastructure deployed successfully
- [ ] Application responding at ALB URL
- [ ] All 6 screenshots taken
- [ ] Evidence logs collected
- [ ] Compliance docs reviewed
- [ ] Scan reports downloaded

After cleanup:

- [ ] All resources destroyed
- [ ] S3 backend deleted
- [ ] No unexpected AWS charges
- [ ] Evidence preserved locally

---

## 🎤 Interview Preparation

### Be Ready to Explain

1. **Why EKS over ECS Fargate?**
   - Answer in `docs/ASSESSMENT-DELIVERABLES.md`

2. **How does encryption work?**
   - All data encrypted at rest with KMS
   - TLS 1.2+ for data in transit
   - See `docs/GCC-COMPLIANCE-MAPPING.md`

3. **What's the deployment strategy?**
   - Rolling update (zero downtime)
   - Automated via CI/CD
   - Manual approval for production

4. **How do you handle secrets?**
   - EKS secrets encrypted with KMS
   - OIDC for GitHub Actions (no keys)
   - Could use AWS Secrets Manager for production

5. **How would you improve this for production?**
   - Multi-region for DR
   - GitOps with Flux/ArgoCD
   - Service mesh for mTLS
   - External DNS automation
   - Cost optimization (Spot, autoscaling)

---

## 📞 Next Steps

1. Deploy following this guide
2. Collect all evidence
3. Run cleanup to avoid charges
4. Review compliance documentation
5. Practice explaining your architecture
6. Submit assessment
7. Ace the interview! 

**Good luck!**
