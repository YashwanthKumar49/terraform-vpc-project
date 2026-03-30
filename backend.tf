# ============================================================
# backend.tf
# Configures remote state storage in S3 with DynamoDB locking.
#
# BEFORE running terraform init:
#   1. Create the S3 bucket:   aws s3 mb s3://my-terraform-state-bucket
#   2. Enable versioning:      aws s3api put-bucket-versioning \
#                                --bucket my-terraform-state-bucket \
#                                --versioning-configuration Status=Enabled
#   3. Create DynamoDB table:  aws dynamodb create-table \
#                                --table-name terraform-lock \
#                                --attribute-definitions AttributeName=LockID,AttributeType=S \
#                                --key-schema AttributeName=LockID,KeyType=HASH \
#                                --billing-mode PAY_PER_REQUEST
# ============================================================

terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"   # <-- replace with your state bucket
    key            = "projects/webapp/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"              # <-- replace with your DynamoDB table
  }
}
