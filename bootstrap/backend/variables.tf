variable "aws_region" {
  description = "AWS region where the Terraform backend resources are created."
  type        = string
  default     = "us-east-1"
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking."
  type        = string
  default     = "terraform-locks-v2"
}

variable "owner" {
  description = "Owner tag applied to bootstrap resources."
  type        = string
  default     = "Felipe"
}

variable "project_name" {
  description = "Project tag applied to bootstrap resources."
  type        = string
  default     = "infra-iac"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name used for Terraform remote state."
  type        = string
  default     = "felipe-tfstate-660830512266-v2"
}
