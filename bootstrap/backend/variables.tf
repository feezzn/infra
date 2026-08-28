variable "aws_region" {
  description = "AWS region where the Terraform backend resources are created."
  type        = string
  default     = "us-east-1"
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

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,48}[a-z0-9]$", var.project_name))
    error_message = "project_name must be lowercase alphanumeric with hyphens, start and end with an alphanumeric character, and be 3 to 50 characters long."
  }
}
