#!/bin/bash
# Setup Terraform Backend - S3 bucket and DynamoDB table

set -e

AWS_REGION="ap-southeast-1"
BUCKET_NAME="gcc-terraform-state-ap-southeast-1"
DYNAMODB_TABLE="terraform-state-lock"
KMS_ALIAS="alias/terraform-state"

echo "=========================================="
echo "Setting up Terraform Backend"
echo "=========================================="

# Create S3 bucket for Terraform state
echo "Creating S3 bucket: $BUCKET_NAME"
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$AWS_REGION" \
  --create-bucket-configuration LocationConstraint="$AWS_REGION" \
  2>/dev/null || echo "Bucket already exists"

# Enable versioning
echo "Enabling versioning on S3 bucket..."
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

# Enable server-side encryption
echo "Enabling encryption on S3 bucket..."
aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      },
      "BucketKeyEnabled": true
    }]
  }'

# Block public access
echo "Blocking public access..."
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Create DynamoDB table for state locking
echo "Creating DynamoDB table: $DYNAMODB_TABLE"
aws dynamodb create-table \
  --table-name "$DYNAMODB_TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$AWS_REGION" \
  2>/dev/null || echo "Table already exists"

echo ""
echo "=========================================="
echo "✅ Terraform Backend Setup Complete!"
echo "=========================================="
echo "S3 Bucket: $BUCKET_NAME"
echo "DynamoDB Table: $DYNAMODB_TABLE"
echo "Region: $AWS_REGION"
echo ""
echo "Note: KMS key will be created by Terraform on first apply"
echo ""
