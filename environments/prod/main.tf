terraform {
  backend "s3" {
    bucket         = "felipe-tfstate-660830512266-v2"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-v2"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "infra-iac"
      Environment = "prod"
      Owner       = "Felipe"
      ManagedBy   = "Terraform"
      CostCenter  = "prod"
    }
  }
}

resource "aws_s3_bucket" "prod_bucket" {
  bucket = "felipe-prod-bucket-660830512266"
}

module "vpc" {
  source = "../../modules/vpc"

  name_prefix = "prod"
  cidr_block  = "10.20.0.0/16"
  az_count    = 2

  enable_public_subnets  = true
  enable_private_subnets = true

  tags = {
    Environment = "prod"
  }
}