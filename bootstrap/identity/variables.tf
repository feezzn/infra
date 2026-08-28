variable "aws_region" {
  description = "AWS region used by the AWS provider."
  type        = string
  default     = "us-east-1"
}

variable "github_branch" {
  description = "GitHub branch allowed to assume the bootstrap identity role."
  type        = string
  default     = "main"

  validation {
    condition     = length(var.github_branch) > 0 && !strcontains(var.github_branch, "*") && !strcontains(var.github_branch, "?")
    error_message = "github_branch must be non-empty and must not contain wildcard characters."
  }
}

variable "github_oidc_audience" {
  description = "Audience configured for GitHub Actions OIDC federation with AWS STS."
  type        = string
  default     = "sts.amazonaws.com"
}

variable "github_owner" {
  description = "GitHub organization or user that owns the repository."
  type        = string
  default     = "feezzn"

  validation {
    condition     = can(regex("^[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?$", var.github_owner))
    error_message = "github_owner must use GitHub owner naming rules and must not contain wildcard characters."
  }
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the bootstrap identity role."
  type        = string
  default     = "infra"

  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+$", var.github_repository)) && !strcontains(var.github_repository, "*") && !strcontains(var.github_repository, "?")
    error_message = "github_repository must be non-empty and must not contain wildcard characters."
  }
}

variable "owner" {
  description = "Owner tag applied to bootstrap identity resources."
  type        = string
  default     = "Felipe"
}

variable "policy_name" {
  description = "Name of the IAM policy attached to the GitHub Actions bootstrap identity role."
  type        = string
  default     = "github-actions-bootstrap-identity-state"
}

variable "project_name" {
  description = "Project tag and prefix used to derive the Terraform state bucket name."
  type        = string
  default     = "infra-iac"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,48}[a-z0-9]$", var.project_name))
    error_message = "project_name must be lowercase alphanumeric with hyphens, start and end with an alphanumeric character, and be 3 to 50 characters long."
  }
}

variable "role_name" {
  description = "Name of the IAM role assumed by GitHub Actions for bootstrap identity."
  type        = string
  default     = "github-actions-bootstrap-identity"
}
