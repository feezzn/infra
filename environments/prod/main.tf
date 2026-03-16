# aqui é para atrelar o state ao s3 e não local.
terraform {
  backend "s3" {
    bucket         = "felipe-tfstate-660830512266-v2"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-v2"
    encrypt        = true
  }
}

#aqui já diz, é o provider e sua região
provider "aws" {
  region = var.region

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

# aqui são os recursos a serem criados.
resource "aws_s3_bucket" "dev_bucket" {
  bucket = "felipe-dev-bucket-660830512266"
}

resource "aws_kms_key" "s3" {
  description             = "KMS key for prod S3 bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "s3" {
  name          = "alias/prod-s3-bucket"
  target_key_id = aws_kms_key.s3.key_id
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dev_bucket" {
  bucket = aws_s3_bucket.dev_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "dev_bucket" {
  bucket = aws_s3_bucket.dev_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "dev_bucket" {
  bucket = aws_s3_bucket.dev_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "vpc" {
  source = "../../modules/vpc"

  name_prefix = "dev"
  cidr_block  = "10.10.0.0/16"

  enable_public_subnets  = true
  enable_private_subnets = true
  enable_nat_gateway     = true

  az_count = 2
}

module "sg_ec2" {
  source = "../../modules/security-group"

  name   = "dev-ec2-sg"
  vpc_id = module.vpc.vpc_id

  ingress_rules = []

  tags = {
    Environment = "dev"
  }
}

module "ec2" {
  source = "../../modules/ec2"

  name              = "dev-ec2"
  subnet_id         = module.vpc.public_subnet_ids[0]
  security_group_id = module.sg_ec2.id

  tags = {
    Environment = "dev"
    Role        = "test"
  }

}