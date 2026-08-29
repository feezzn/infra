locals {
  environment = "lab"
  name_prefix = "${var.project_name}-${local.environment}"

  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)

  public_subnets = {
    for index, cidr_block in var.public_subnet_cidrs : tostring(index) => {
      availability_zone = local.availability_zones[index]
      cidr_block        = cidr_block
      name              = "${local.name_prefix}-public-${index + 1}"
    }
  }

  private_subnets = {
    for index, cidr_block in var.private_subnet_cidrs : tostring(index) => {
      availability_zone = local.availability_zones[index]
      cidr_block        = cidr_block
      name              = "${local.name_prefix}-private-${index + 1}"
    }
  }

  common_tags = {
    Project     = var.project_name
    Environment = local.environment
    Owner       = var.owner
    ManagedBy   = "Terraform"
    CostCenter  = "platform"
  }

}
