terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
  }
  # Required version of Terraform
  required_version = ">= 1.1.5"

  backend "s3" {
    bucket         = "my-terraform-state-bucket"      # The name of the S3 bucket
    key            = "path/to/your/terraform.tfstate" # The path to your state file in the bucket
    region         = "us-east-2"                      # The region where the S3 bucket is located
    encrypt        = true                             # Enable server-side encryption
    dynamodb_table = "terraform-lock"                 # Optional: DynamoDB table for state locking
    acl            = "private"                        # S3 bucket ACL, default is "private"
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"


}
