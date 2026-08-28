output "backend_config" {
  description = "Values used by environment backend blocks."
  value = {
    bucket       = aws_s3_bucket.terraform_state.id
    encrypt      = true
    region       = var.aws_region
    use_lockfile = true
  }
}

output "aws_account_id" {
  description = "AWS account ID used to derive the Terraform state bucket name."
  value       = data.aws_caller_identity.current.account_id
}

output "state_bucket_arn" {
  description = "ARN of the S3 bucket used for Terraform remote state."
  value       = aws_s3_bucket.terraform_state.arn
}

output "state_bucket_name" {
  description = "Name of the S3 bucket used for Terraform remote state."
  value       = aws_s3_bucket.terraform_state.id
}
