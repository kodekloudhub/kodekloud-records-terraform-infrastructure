terraform {
  required_version = ">= 1.3.0"
  
  # This backend configuration will be used after the bucket is created
  # You'll need to run terraform init -reconfigure after first applying
  backend "s3" {
    key     = "global/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
    # The bucket name will be set during terraform init with -backend-config
    bucket  = "terraform-state-code-file"
  }
}

# Generate a unique ID for the bucket
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Create the S3 bucket for storing Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-${random_id.bucket_suffix.hex}"
  
  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning for the state bucket
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption for the state bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access to the state bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Output the bucket name for use in the backend configuration
output "state_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
  description = "The name of the S3 bucket for Terraform state storage"
}

# IAM User Module
module "iam_users" {
  source = "./modules/iam-user"
  
  iam_usernames = var.iam_usernames
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "arn:aws:iam::aws:policy/IAMUserChangePassword"
  ]
  
  inline_policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:List*",
          "s3:Get*",
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::dev-bucket",
          "arn:aws:s3:::dev-bucket/*"
        ]
      },
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.terraform_state.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.terraform_state.bucket}/*"
        ]
      }
    ]
  })
}

