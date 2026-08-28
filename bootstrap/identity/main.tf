locals {
  github_oidc_provider_host = "token.actions.githubusercontent.com"
  github_oidc_provider_url  = "https://${local.github_oidc_provider_host}"

  github_repository_full_name = "${var.github_owner}/${var.github_repository}"
  github_oidc_subject         = "repo:${local.github_repository_full_name}:ref:refs/heads/${var.github_branch}"

  identity_state_key       = "bootstrap/identity/terraform.tfstate"
  identity_lockfile_key    = "${local.identity_state_key}.tflock"
  state_bucket_name        = lower("${var.project_name}-${data.aws_caller_identity.current.account_id}-tfstate")
  state_bucket_arn         = "arn:${data.aws_partition.current.partition}:s3:::${local.state_bucket_name}"
  identity_state_object    = "${local.state_bucket_arn}/${local.identity_state_key}"
  identity_lockfile_object = "${local.state_bucket_arn}/${local.identity_lockfile_key}"

  common_tags = {
    Project     = var.project_name
    Environment = "bootstrap"
    Owner       = var.owner
    ManagedBy   = "Terraform"
    CostCenter  = "platform"
  }
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

resource "aws_iam_openid_connect_provider" "github" {
  url = local.github_oidc_provider_url

  client_id_list = [
    var.github_oidc_audience,
  ]

  tags = {
    Name = "github-actions"
  }
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    sid     = "AllowGitHubActionsMainBranch"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.github_oidc_provider_host}:aud"
      values   = [var.github_oidc_audience]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.github_oidc_provider_host}:sub"
      values   = [local.github_oidc_subject]
    }
  }
}

resource "aws_iam_role" "github_actions_bootstrap_identity" {
  name               = var.role_name
  description        = "GitHub Actions role for managing bootstrap identity Terraform state."
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  tags = {
    Name = var.role_name
  }
}

data "aws_iam_policy_document" "identity_state" {
  statement {
    sid       = "ListIdentityTerraformState"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.state_bucket_arn]

    condition {
      test     = "StringEquals"
      variable = "s3:prefix"
      values = [
        local.identity_state_key,
        local.identity_lockfile_key,
      ]
    }
  }

  statement {
    sid    = "ReadWriteIdentityTerraformState"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [local.identity_state_object]
  }

  statement {
    sid    = "ManageIdentityTerraformStateLock"
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [local.identity_lockfile_object]
  }
}

resource "aws_iam_policy" "identity_state" {
  name        = var.policy_name
  description = "Allows Terraform access only to the bootstrap identity state and lockfile."
  policy      = data.aws_iam_policy_document.identity_state.json

  tags = {
    Name = var.policy_name
  }
}

resource "aws_iam_role_policy_attachment" "identity_state" {
  role       = aws_iam_role.github_actions_bootstrap_identity.name
  policy_arn = aws_iam_policy.identity_state.arn
}
