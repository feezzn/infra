variable "aws_region" {
  description = "AWS region where the lab foundation is planned."
  type        = string
  default     = "us-east-1"
}

variable "enable_eks_egress" {
  description = "Whether to create the optional NAT-based outbound IPv4 path for future private EKS nodes."
  type        = bool
  default     = true
}

variable "owner" {
  description = "Owner tag applied to lab resources."
  type        = string
  default     = "Felipe"
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private lab subnets."
  type        = list(string)
  default = [
    "10.10.10.0/24",
    "10.10.11.0/24",
  ]

  validation {
    condition     = length(var.private_subnet_cidrs) == 2 && alltrue([for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "private_subnet_cidrs must contain exactly two valid CIDR blocks."
  }
}

variable "project_name" {
  description = "Project tag and naming prefix applied to lab resources."
  type        = string
  default     = "infra-iac"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,48}[a-z0-9]$", var.project_name))
    error_message = "project_name must be lowercase alphanumeric with hyphens, start and end with an alphanumeric character, and be 3 to 50 characters long."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public lab subnets."
  type        = list(string)
  default = [
    "10.10.0.0/24",
    "10.10.1.0/24",
  ]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2 && alltrue([for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "public_subnet_cidrs must contain exactly two valid CIDR blocks."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the lab VPC."
  type        = string
  default     = "10.10.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}
