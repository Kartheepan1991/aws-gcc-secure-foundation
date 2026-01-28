# Interview Assessment Notes

## Project Scope
This is a **DEV ENVIRONMENT ONLY** project created for interview assessment purposes.

## What's Included
-  Development environment fully configured
-  All infrastructure modules (VPC, EKS, Security, Monitoring)
-  Sample application with Kubernetes manifests
-  Security best practices for GCC compliance
-  CI/CD pipeline examples

## What's NOT Included
- NO: Production environment (folder exists but not configured)
- NO: Multi-region deployment
- NO: Production-grade DR/backup strategies

## Local Development
All documentation and README files are kept **LOCAL ONLY** and will not be pushed to remote repository as per project requirements.

## Environment Variables
Create your own `terraform.tfvars` files based on the `.example` files provided. These are gitignored for security.

## Deployment
```bash
# Navigate to dev environment
cd terraform/environments/dev

# Initialize Terraform
terraform init

# Review plan
terraform plan

# Apply (for assessment demonstration)
terraform apply
```

## Evidence Collection
Save screenshots and evidence in `docs/evidence/` folder (gitignored).
