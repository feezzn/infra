output "aws_account_id" {
  description = "AWS account ID where the GitHub OIDC identity resources are created."
  value       = data.aws_caller_identity.current.account_id
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions bootstrap identity role."
  value       = aws_iam_role.github_actions_bootstrap_identity.arn
}

output "github_actions_role_name" {
  description = "Name of the GitHub Actions bootstrap identity role."
  value       = aws_iam_role.github_actions_bootstrap_identity.name
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_oidc_subject" {
  description = "GitHub OIDC sub claim allowed to assume the role."
  value       = local.github_oidc_subject
}

output "identity_state_key" {
  description = "S3 key used by the bootstrap identity Terraform state."
  value       = local.identity_state_key
}

output "identity_state_policy_arn" {
  description = "ARN of the policy granting access to the bootstrap identity state."
  value       = aws_iam_policy.identity_state.arn
}

output "permissions_policy" {
  description = "Permissions policy attached to the GitHub Actions bootstrap identity role."
  value       = jsondecode(data.aws_iam_policy_document.identity_state.json)
}

output "state_bucket_name" {
  description = "Name of the S3 bucket that stores Terraform remote state."
  value       = local.state_bucket_name
}

output "terraform_lab_apply_permissions_policy" {
  description = "Permissions policy attached to the GitHub Actions Terraform lab apply role."
  value       = jsondecode(data.aws_iam_policy_document.terraform_lab_apply.json)
}

output "terraform_lab_apply_policy_arn" {
  description = "ARN of the policy granting Terraform apply access to the lab state and network foundation."
  value       = aws_iam_policy.terraform_lab_apply.arn
}

output "terraform_lab_apply_role_arn" {
  description = "ARN of the GitHub Actions Terraform lab apply role."
  value       = aws_iam_role.github_actions_terraform_lab_apply.arn
}

output "terraform_lab_apply_role_name" {
  description = "Name of the GitHub Actions Terraform lab apply role."
  value       = aws_iam_role.github_actions_terraform_lab_apply.name
}

output "terraform_lab_apply_trust_policy" {
  description = "Trust policy for the GitHub Actions Terraform lab apply role."
  value       = jsondecode(data.aws_iam_policy_document.github_actions_terraform_lab_apply_assume_role.json)
}

output "terraform_lab_plan_permissions_policy" {
  description = "Permissions policy attached to the GitHub Actions Terraform lab plan role."
  value       = jsondecode(data.aws_iam_policy_document.terraform_lab_plan.json)
}

output "terraform_lab_plan_policy_arn" {
  description = "ARN of the policy granting read-only Terraform plan access to the lab state and network foundation."
  value       = aws_iam_policy.terraform_lab_plan.arn
}

output "terraform_lab_plan_role_arn" {
  description = "ARN of the GitHub Actions Terraform lab plan role."
  value       = aws_iam_role.github_actions_terraform_lab_plan.arn
}

output "terraform_lab_plan_role_name" {
  description = "Name of the GitHub Actions Terraform lab plan role."
  value       = aws_iam_role.github_actions_terraform_lab_plan.name
}

output "terraform_lab_plan_trust_policy" {
  description = "Trust policy for the GitHub Actions Terraform lab plan role."
  value       = jsondecode(data.aws_iam_policy_document.github_actions_terraform_lab_plan_assume_role.json)
}

output "terraform_lab_plan_workflow_notes" {
  description = "Operational notes for the future pull request Terraform plan workflow."
  value = {
    terraform_plan_command    = "terraform plan -lock=false"
    role_assumption_condition = "github.event.pull_request.head.repo.full_name == github.repository"
  }
}

output "terraform_lab_eks_apply_eks_access_policy" {
  description = "EKS access-entry mutation policy attached to the GitHub Actions Terraform lab EKS apply role."
  value       = jsondecode(data.aws_iam_policy_document.terraform_lab_eks_apply_eks_access.json)
}

output "terraform_lab_eks_apply_eks_access_policy_arn" {
  description = "ARN of the EKS access-entry mutation policy for the lab EKS apply role."
  value       = aws_iam_policy.terraform_lab_eks_apply_eks_access.arn
}

output "terraform_lab_eks_apply_eks_access_policy_size" {
  description = "Minified character size of the lab EKS access-entry mutation policy."
  value       = length(data.aws_iam_policy_document.terraform_lab_eks_apply_eks_access.json)
}

output "terraform_lab_eks_apply_eks_addons_policy" {
  description = "EKS add-on mutation policy attached to the GitHub Actions Terraform lab EKS apply role."
  value       = jsondecode(data.aws_iam_policy_document.terraform_lab_eks_apply_eks_addons.json)
}

output "terraform_lab_eks_apply_eks_addons_policy_arn" {
  description = "ARN of the EKS add-on mutation policy for the lab EKS apply role."
  value       = aws_iam_policy.terraform_lab_eks_apply_eks_addons.arn
}

output "terraform_lab_eks_apply_eks_addons_policy_size" {
  description = "Minified character size of the lab EKS add-on mutation policy."
  value       = length(data.aws_iam_policy_document.terraform_lab_eks_apply_eks_addons.json)
}

output "terraform_lab_eks_apply_eks_cluster_policy" {
  description = "EKS cluster and node group mutation policy attached to the GitHub Actions Terraform lab EKS apply role."
  value       = jsondecode(data.aws_iam_policy_document.terraform_lab_eks_apply_eks_cluster.json)
}

output "terraform_lab_eks_apply_eks_cluster_policy_arn" {
  description = "ARN of the EKS cluster and node group mutation policy for the lab EKS apply role."
  value       = aws_iam_policy.terraform_lab_eks_apply_eks_cluster.arn
}

output "terraform_lab_eks_apply_eks_cluster_policy_size" {
  description = "Minified character size of the lab EKS cluster and node group mutation policy."
  value       = length(data.aws_iam_policy_document.terraform_lab_eks_apply_eks_cluster.json)
}

output "terraform_lab_eks_apply_eks_tags_policy" {
  description = "EKS tagging policy attached to the GitHub Actions Terraform lab EKS apply role."
  value       = jsondecode(data.aws_iam_policy_document.terraform_lab_eks_apply_eks_tags.json)
}

output "terraform_lab_eks_apply_eks_tags_policy_arn" {
  description = "ARN of the EKS tagging policy for the lab EKS apply role."
  value       = aws_iam_policy.terraform_lab_eks_apply_eks_tags.arn
}

output "terraform_lab_eks_apply_eks_tags_policy_size" {
  description = "Minified character size of the lab EKS tagging policy."
  value       = length(data.aws_iam_policy_document.terraform_lab_eks_apply_eks_tags.json)
}

output "terraform_lab_eks_apply_iam_policies_policy" {
  description = "IAM policy and role attachment mutation policy attached to the GitHub Actions Terraform lab EKS apply role."
  value       = jsondecode(data.aws_iam_policy_document.terraform_lab_eks_apply_iam_policies.json)
}

output "terraform_lab_eks_apply_iam_policies_policy_arn" {
  description = "ARN of the IAM policy and role attachment mutation policy for the lab EKS apply role."
  value       = aws_iam_policy.terraform_lab_eks_apply_iam_policies.arn
}

output "terraform_lab_eks_apply_iam_policies_policy_size" {
  description = "Minified character size of the lab EKS IAM policy and role attachment mutation policy."
  value       = length(data.aws_iam_policy_document.terraform_lab_eks_apply_iam_policies.json)
}

output "terraform_lab_eks_apply_iam_roles_policy" {
  description = "IAM role mutation policy attached to the GitHub Actions Terraform lab EKS apply role."
  value       = jsondecode(data.aws_iam_policy_document.terraform_lab_eks_apply_iam_roles.json)
}

output "terraform_lab_eks_apply_iam_roles_policy_arn" {
  description = "ARN of the IAM role mutation policy for the lab EKS apply role."
  value       = aws_iam_policy.terraform_lab_eks_apply_iam_roles.arn
}

output "terraform_lab_eks_apply_iam_roles_policy_size" {
  description = "Minified character size of the lab EKS IAM role mutation policy."
  value       = length(data.aws_iam_policy_document.terraform_lab_eks_apply_iam_roles.json)
}

output "terraform_lab_eks_apply_passrole_policy" {
  description = "PassRole and service-linked role policy attached to the GitHub Actions Terraform lab EKS apply role."
  value       = jsondecode(data.aws_iam_policy_document.terraform_lab_eks_apply_passrole.json)
}

output "terraform_lab_eks_apply_passrole_policy_arn" {
  description = "ARN of the PassRole and service-linked role policy for the lab EKS apply role."
  value       = aws_iam_policy.terraform_lab_eks_apply_passrole.arn
}

output "terraform_lab_eks_apply_passrole_policy_size" {
  description = "Minified character size of the lab EKS PassRole and service-linked role policy."
  value       = length(data.aws_iam_policy_document.terraform_lab_eks_apply_passrole.json)
}

output "terraform_lab_eks_apply_role_arn" {
  description = "ARN of the GitHub Actions Terraform lab EKS apply role."
  value       = aws_iam_role.github_actions_terraform_lab_eks_apply.arn
}

output "terraform_lab_eks_apply_role_name" {
  description = "Name of the GitHub Actions Terraform lab EKS apply role."
  value       = aws_iam_role.github_actions_terraform_lab_eks_apply.name
}

output "terraform_lab_eks_apply_state_policy" {
  description = "State policy attached to the GitHub Actions Terraform lab EKS apply role."
  value       = jsondecode(data.aws_iam_policy_document.terraform_lab_eks_apply_state.json)
}

output "terraform_lab_eks_apply_state_policy_arn" {
  description = "ARN of the state policy for the lab EKS apply role."
  value       = aws_iam_policy.terraform_lab_eks_apply_state.arn
}

output "terraform_lab_eks_apply_state_policy_size" {
  description = "Minified character size of the lab EKS apply state policy."
  value       = length(data.aws_iam_policy_document.terraform_lab_eks_apply_state.json)
}

output "terraform_lab_eks_apply_trust_policy" {
  description = "Trust policy for the GitHub Actions Terraform lab EKS apply role."
  value       = jsondecode(data.aws_iam_policy_document.github_actions_terraform_lab_eks_apply_assume_role.json)
}

output "terraform_lab_eks_plan_role_arn" {
  description = "ARN of the GitHub Actions Terraform lab EKS plan role."
  value       = aws_iam_role.github_actions_terraform_lab_eks_plan.arn
}

output "terraform_lab_eks_plan_role_name" {
  description = "Name of the GitHub Actions Terraform lab EKS plan role."
  value       = aws_iam_role.github_actions_terraform_lab_eks_plan.name
}

output "terraform_lab_eks_plan_state_policy" {
  description = "State policy attached to the GitHub Actions Terraform lab EKS plan role."
  value       = jsondecode(data.aws_iam_policy_document.terraform_lab_eks_plan_state.json)
}

output "terraform_lab_eks_plan_state_policy_arn" {
  description = "ARN of the state policy for the lab EKS plan role."
  value       = aws_iam_policy.terraform_lab_eks_plan_state.arn
}

output "terraform_lab_eks_plan_state_policy_size" {
  description = "Minified character size of the lab EKS plan state policy."
  value       = length(data.aws_iam_policy_document.terraform_lab_eks_plan_state.json)
}

output "terraform_lab_eks_plan_trust_policy" {
  description = "Trust policy for the GitHub Actions Terraform lab EKS plan role."
  value       = jsondecode(data.aws_iam_policy_document.github_actions_terraform_lab_eks_plan_assume_role.json)
}

output "terraform_lab_eks_read_policy" {
  description = "Shared read-only AWS refresh policy attached to both lab EKS roles."
  value       = jsondecode(data.aws_iam_policy_document.terraform_lab_eks_read.json)
}

output "terraform_lab_eks_read_policy_arn" {
  description = "ARN of the shared read-only AWS refresh policy for lab EKS roles."
  value       = aws_iam_policy.terraform_lab_eks_read.arn
}

output "terraform_lab_eks_read_policy_size" {
  description = "Minified character size of the shared lab EKS read policy."
  value       = length(data.aws_iam_policy_document.terraform_lab_eks_read.json)
}

output "trust_policy" {
  description = "Trust policy for the GitHub Actions bootstrap identity role."
  value       = jsondecode(data.aws_iam_policy_document.github_actions_assume_role.json)
}
