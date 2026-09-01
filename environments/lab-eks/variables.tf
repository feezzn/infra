variable "aws_region" {
  description = "AWS region for the lab EKS environment."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = var.aws_region == "us-east-1"
    error_message = "The lab EKS environment is currently designed only for us-east-1."
  }
}

variable "project_name" {
  description = "Project name used for tags and resource names."
  type        = string
  default     = "infra-iac"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}[a-z0-9]$", var.project_name))
    error_message = "project_name must be lowercase alphanumeric with hyphens, start with a letter, and end with a letter or number."
  }
}

variable "owner" {
  description = "Owner tag value for lab resources."
  type        = string
  default     = "Felipe"
}

variable "network_state_bucket" {
  description = "S3 bucket containing the persistent lab network Terraform state."
  type        = string
  default     = "infra-iac-978121310268-tfstate"
}

variable "network_state_key" {
  description = "S3 key for the persistent lab network Terraform state."
  type        = string
  default     = "environments/lab/terraform.tfstate"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes minor version."
  type        = string
  default     = "1.36"

  validation {
    condition     = var.kubernetes_version == "1.36"
    error_message = "This lab root is intentionally pinned to Kubernetes 1.36."
  }
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to reach the public EKS API endpoint."
  type        = list(string)
  # TODO: Temporary lab bootstrap behavior. Restrict this after EKS access is proven.
  default = ["0.0.0.0/0"]

  validation {
    condition     = length(var.cluster_endpoint_public_access_cidrs) > 0
    error_message = "At least one public access CIDR must be provided while public endpoint access is enabled."
  }
}

variable "node_instance_types" {
  description = "Instance types for the managed node group."
  type        = list(string)
  default     = ["t3.medium"]

  validation {
    condition     = length(var.node_instance_types) > 0
    error_message = "At least one node instance type must be provided."
  }
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the managed node group."
  type        = number
  default     = 2
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the managed node group."
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the managed node group."
  type        = number
  default     = 3
}

variable "eks_admin_role_name" {
  description = "Stable IAM role name used for human Kubernetes administration through EKS Access Entries."
  type        = string
  default     = "eks-lab-admin"
}

variable "eks_admin_trusted_user_name" {
  description = "Existing IAM user name allowed to assume the EKS admin role with MFA when eks_admin_trusted_principal_arn is not set."
  type        = string
  default     = "platform-admin"
}

variable "eks_admin_trusted_principal_arn" {
  description = "Optional stable IAM user or role ARN allowed to assume eks-lab-admin with MFA. Do not use STS assumed-role session ARNs."
  type        = string
  default     = null

  validation {
    condition = (
      var.eks_admin_trusted_principal_arn == null ||
      (
        can(regex("^arn:[^:]+:iam::[0-9]{12}:(user|role)/.+$", var.eks_admin_trusted_principal_arn)) &&
        !can(regex(":assumed-role/", var.eks_admin_trusted_principal_arn))
      )
    )
    error_message = "eks_admin_trusted_principal_arn must be a stable IAM user or role ARN, not an STS assumed-role session ARN."
  }
}
