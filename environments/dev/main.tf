# aqui é para atrelar o state ao s3 e não local.
terraform {
  backend "s3" {
    bucket         = "felipe-tfstate-660830512266-v2"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-v2"
    encrypt        = true
  }
}

#aqui já diz, é o provider e sua região
provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
      Project     = "infra-iac"
      Environment = "dev"
      Owner       = "Felipe"
      ManagedBy   = "Terraform"
      CostCenter  = "dev"
    }
  }
}

# aqui são os recursos a serem criados.
resource "aws_s3_bucket" "dev_bucket" {
  bucket = "felipe-dev-bucket-660830512266"
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