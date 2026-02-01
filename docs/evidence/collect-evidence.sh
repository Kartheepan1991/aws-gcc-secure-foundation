#!/bin/bash
#
# Evidence Collection Script for Assignment 1
# Collects all CLI outputs and saves to evidence directory
#

set -e

EVIDENCE_DIR="/home/kartheepan/my-projects/aws-gcc-secure-foundation/docs/evidence/cli"
REGION="ap-southeast-1"
CLUSTER_NAME="dev-eks-cluster"

echo "=========================================="
echo "Collecting Assignment 1 Evidence"
echo "=========================================="
echo ""

# Update kubeconfig
echo "Updating kubeconfig..."
aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$REGION" > /dev/null 2>&1

# 1. Cluster Info
echo "Collecting cluster info..."
kubectl cluster-info > "$EVIDENCE_DIR/cluster-info.txt"
echo "✓ cluster-info.txt"

# 2. Nodes
echo "Collecting node information..."
kubectl get nodes -o wide > "$EVIDENCE_DIR/nodes.txt"
kubectl describe nodes > "$EVIDENCE_DIR/nodes-describe.txt"
echo "✓ nodes.txt, nodes-describe.txt"

# 3. Pods
echo "Collecting pod information..."
kubectl get pods -A -o wide > "$EVIDENCE_DIR/pods-all-namespaces.txt"
kubectl get pods -n default -o wide > "$EVIDENCE_DIR/pods-default.txt"
kubectl get pods -n kube-system -o wide > "$EVIDENCE_DIR/pods-kube-system.txt"
echo "✓ pods-*.txt"

# 4. Services
echo "Collecting service information..."
kubectl get svc -A > "$EVIDENCE_DIR/services-all.txt"
kubectl get svc -n default -o wide > "$EVIDENCE_DIR/services-default.txt"
echo "✓ services-*.txt"

# 5. Deployments
echo "Collecting deployment information..."
kubectl get deployments -A > "$EVIDENCE_DIR/deployments-all.txt"
kubectl get deployments -n default -o yaml > "$EVIDENCE_DIR/deployments-default.yaml"
echo "✓ deployments-*.txt"

# 6. ConfigMaps & Secrets
echo "Collecting ConfigMaps..."
kubectl get configmaps -A > "$EVIDENCE_DIR/configmaps.txt"
echo "✓ configmaps.txt"

# 7. EKS Cluster Details
echo "Collecting EKS cluster details..."
aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" > "$EVIDENCE_DIR/eks-cluster.json"
echo "✓ eks-cluster.json"

# 8. Node Group Details
echo "Collecting node group details..."
aws eks describe-nodegroup \
  --cluster-name "$CLUSTER_NAME" \
  --nodegroup-name dev-node-group \
  --region "$REGION" > "$EVIDENCE_DIR/eks-nodegroup.json"
echo "✓ eks-nodegroup.json"

# 9. ECR Images
echo "Collecting ECR repository info..."
aws ecr describe-repository --repository-name gcc-app --region "$REGION" > "$EVIDENCE_DIR/ecr-repository.json" 2>/dev/null || echo "ECR repository not found yet"
aws ecr describe-images --repository-name gcc-app --region "$REGION" > "$EVIDENCE_DIR/ecr-images.json" 2>/dev/null || echo "No images in ECR yet"
echo "✓ ecr-*.json"

# 10. VPC Details
echo "Collecting VPC information..."
VPC_ID=$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" --query 'cluster.resourcesVpcConfig.vpcId' --output text)
aws ec2 describe-vpcs --vpc-ids "$VPC_ID" --region "$REGION" > "$EVIDENCE_DIR/vpc-details.json"
echo "✓ vpc-details.json"

# 11. CloudWatch Log Groups
echo "Collecting CloudWatch log groups..."
aws logs describe-log-groups --region "$REGION" --log-group-name-prefix "/aws" > "$EVIDENCE_DIR/cloudwatch-log-groups.json"
echo "✓ cloudwatch-log-groups.json"

# 12. IAM Roles
echo "Collecting IAM roles..."
aws iam get-role --role-name dev-eks-cluster-role > "$EVIDENCE_DIR/iam-cluster-role.json" 2>/dev/null || echo "Cluster role not found"
aws iam get-role --role-name dev-node-group-role > "$EVIDENCE_DIR/iam-node-role.json" 2>/dev/null || echo "Node role not found"
echo "✓ iam-*.json"

# 13. Summary Report
echo ""
echo "Generating summary report..."
cat > "$EVIDENCE_DIR/summary.txt" << EOF
Evidence Collection Summary
Generated: $(date)
Cluster: $CLUSTER_NAME
Region: $REGION

Files Generated:
==================
$(ls -lh "$EVIDENCE_DIR" | tail -n +2)

Cluster Status:
==================
$(kubectl get nodes)

Pods Status:
==================
$(kubectl get pods -A)

Services:
==================
$(kubectl get svc -A)

EKS Version:
==================
$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" --query 'cluster.version' --output text)
EOF

echo "✓ summary.txt"

echo ""
echo "=========================================="
echo "Evidence collection complete!"
echo "=========================================="
echo "Location: $EVIDENCE_DIR"
echo ""
echo "Files created:"
ls -1 "$EVIDENCE_DIR"
echo ""

exit 0
