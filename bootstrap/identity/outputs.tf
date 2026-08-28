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

output "trust_policy" {
  description = "Trust policy for the GitHub Actions bootstrap identity role."
  value       = jsondecode(data.aws_iam_policy_document.github_actions_assume_role.json)
}
