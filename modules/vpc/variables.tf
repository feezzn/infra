variable "name_prefix" {
  type        = string
  description = "Prefix used to name resources (e.g., dev, prod)."
}

variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC."
}

variable "az_count" {
  type        = number
  description = "Number of AZs/subnets to create."
  default     = 2
}

variable "public_subnet_offset" {
  type        = number
  description = "Offset used to compute public subnet CIDRs."
  default     = 0
}

variable "private_subnet_offset" {
  type        = number
  description = "Offset used to compute private subnet CIDRs (avoid overlapping with public)."
  default     = 10
}

variable "enable_public_subnets" {
  type        = bool
  description = "Whether to create public subnets and public route table."
  default     = true
}

variable "enable_private_subnets" {
  type        = bool
  description = "Whether to create private subnets and private route table."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Extra tags to apply."
  default     = {}
}

variable "enable_vpc_endpoints" {
  type    = bool
  default = true
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable NAT gateway for private subnets egress"
  default     = false
}

variable "single_nat_gateway" {
  type        = bool
  description = "If true, create only one NAT gateway (dev/lab). If false, create one per AZ."
  default     = true
}