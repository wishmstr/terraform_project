terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # Required version of Terraform
  required_version = ">= 1.1.5"

  # backend "s3" {
  #   bucket         = "wishmstr-terraform-state-bucket" # The name of the S3 bucket
  #   key            = "global/s3/terraform.tfstate"     # The path to your state file in the bucket
  #   region         = "us-east-2"                       # The region where the S3 bucket is located
  #   encrypt        = true                              # Enable server-side encryption
  #   dynamodb_table = "terraform-lock"                  # Optional: DynamoDB table for state locking
  #   acl            = "private"                         # S3 bucket ACL, default is "private"
  # assume_role {
  #   role_arn = var.aws_terraform_arn
  # }
  # }
}

provider "aws" {
  # region = var.aws_region

  # access_key = var.aws_secret_access_key
  # secret_key = var.aws_secret_key_id
  # assume_role {
  #   role_arn = var.aws_terraform_arn
  # }
}

data "aws_availability_zones" "available" {
  state = "available"


}

