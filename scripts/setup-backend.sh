#!/bin/bash
# Setup S3 bucket and DynamoDB table for Terraform state
set -e

AWS_REGION="${AWS_REGION:-ap-southeast-1}"
BUCKET_NAME="gcc-terraform-state-${AWS_REGION}"
DYNAMODB_TABLE="terraform-state-lock"

echo "Setting up Terraform backend..."
echo "Region: $AWS_REGION"
echo "Bucket: $BUCKET_NAME"
echo ""

# Create S3 bucket
if aws s3 ls "s3://$BUCKET_NAME" 2>/dev/null; then
    echo "[EXISTS] S3 bucket already exists"
else
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$AWS_REGION" \
        --create-bucket-configuration LocationConstraint="$AWS_REGION"
    
    aws s3api put-bucket-versioning \
        --bucket "$BUCKET_NAME" \
        --versioning-configuration Status=Enabled
    
    aws s3api put-bucket-encryption \
        --bucket "$BUCKET_NAME" \
        --server-side-encryption-configuration '{
            "Rules": [{
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }]
        }'
    
    aws s3api put-public-access-block \
        --bucket "$BUCKET_NAME" \
        --public-access-block-configuration \
            BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
    
    echo "[CREATED] S3 bucket: $BUCKET_NAME"
fi

# Create DynamoDB table
if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" --region "$AWS_REGION" &>/dev/null; then
    echo "[EXISTS] DynamoDB table already exists"
else
    aws dynamodb create-table \
        --table-name "$DYNAMODB_TABLE" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region "$AWS_REGION" >/dev/null
    
    echo "[CREATED] DynamoDB table: $DYNAMODB_TABLE"
fi

echo ""
echo "Backend setup complete!"
echo "Now run: cd terraform/environments/dev && terraform init"
