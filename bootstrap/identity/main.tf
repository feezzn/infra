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

  github_oidc_pull_request_subject = "repo:${local.github_repository_full_name}:pull_request"

  terraform_lab_plan_role_name   = "github-actions-terraform-lab-plan"
  terraform_lab_plan_policy_name = "github-actions-terraform-lab-plan"

  terraform_lab_apply_role_name    = "github-actions-terraform-lab-apply"
  terraform_lab_apply_policy_name  = "github-actions-terraform-lab-apply"
  terraform_lab_egress_policy_name = "github-actions-terraform-lab-egress"

  lab_environment                     = "lab"
  github_oidc_lab_environment_subject = "repo:${local.github_repository_full_name}:environment:${local.lab_environment}"
  lab_state_key                       = "environments/lab/terraform.tfstate"
  lab_lockfile_key                    = "${local.lab_state_key}.tflock"
  lab_state_object                    = "${local.state_bucket_arn}/${local.lab_state_key}"
  lab_lockfile_object                 = "${local.state_bucket_arn}/${local.lab_lockfile_key}"

  ec2_vpc_arn              = "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:vpc/*"
  ec2_subnet_arn           = "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:subnet/*"
  ec2_internet_gateway_arn = "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:internet-gateway/*"
  ec2_route_table_arn      = "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:route-table/*"
  ec2_elastic_ip_arn       = "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:elastic-ip/*"
  ec2_nat_gateway_arn      = "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:natgateway/*"

  terraform_lab_network_resource_arns = [
    local.ec2_internet_gateway_arn,
    local.ec2_route_table_arn,
    local.ec2_subnet_arn,
    local.ec2_vpc_arn,
  ]

  terraform_lab_egress_resource_arns = [
    local.ec2_elastic_ip_arn,
    local.ec2_nat_gateway_arn,
  ]

  terraform_lab_request_tag_keys = [
    "CostCenter",
    "Environment",
    "ManagedBy",
    "Name",
    "Owner",
    "Project",
    "Purpose",
    "Tier",
  ]

  terraform_lab_mutable_tag_keys = [
    "CostCenter",
    "ManagedBy",
    "Name",
    "Owner",
    "Purpose",
    "Tier",
  ]

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

data "aws_iam_policy_document" "github_actions_terraform_lab_plan_assume_role" {
  statement {
    sid     = "AllowGitHubActionsPullRequests"
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
      values   = [local.github_oidc_pull_request_subject]
    }
  }
}

resource "aws_iam_role" "github_actions_terraform_lab_plan" {
  name               = local.terraform_lab_plan_role_name
  description        = "GitHub Actions role for read-only Terraform plans in environments/lab."
  assume_role_policy = data.aws_iam_policy_document.github_actions_terraform_lab_plan_assume_role.json

  tags = {
    Name = local.terraform_lab_plan_role_name
  }
}

data "aws_iam_policy_document" "terraform_lab_plan" {
  statement {
    sid       = "ListLabTerraformState"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.state_bucket_arn]

    condition {
      test     = "StringEquals"
      variable = "s3:prefix"
      values   = [local.lab_state_key]
    }
  }

  statement {
    sid     = "ReadLabTerraformState"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      local.lab_state_object,
    ]
  }

  statement {
    sid    = "ReadEc2LabNetworkFoundation"
    effect = "Allow"
    actions = [
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeAddresses",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNatGateways",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcAttribute",
      "ec2:DescribeVpcs",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:Region"
      values   = [var.aws_region]
    }
  }
}

resource "aws_iam_policy" "terraform_lab_plan" {
  name        = local.terraform_lab_plan_policy_name
  description = "Allows read-only Terraform plans for environments/lab."
  policy      = data.aws_iam_policy_document.terraform_lab_plan.json

  tags = {
    Name = local.terraform_lab_plan_policy_name
  }
}

resource "aws_iam_role_policy_attachment" "terraform_lab_plan" {
  role       = aws_iam_role.github_actions_terraform_lab_plan.name
  policy_arn = aws_iam_policy.terraform_lab_plan.arn
}

data "aws_iam_policy_document" "github_actions_terraform_lab_apply_assume_role" {
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
      values   = [local.github_oidc_lab_environment_subject]
    }
  }
}

resource "aws_iam_role" "github_actions_terraform_lab_apply" {
  name               = local.terraform_lab_apply_role_name
  description        = "GitHub Actions role for applying Terraform changes in environments/lab."
  assume_role_policy = data.aws_iam_policy_document.github_actions_terraform_lab_apply_assume_role.json

  tags = {
    Name = local.terraform_lab_apply_role_name
  }
}

data "aws_iam_policy_document" "terraform_lab_apply" {
  statement {
    sid       = "ListLabTerraformState"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.state_bucket_arn]

    condition {
      test     = "StringEquals"
      variable = "s3:prefix"
      values = [
        local.lab_state_key,
        local.lab_lockfile_key,
      ]
    }
  }

  statement {
    sid    = "ReadWriteLabTerraformState"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [local.lab_state_object]
  }

  statement {
    sid    = "ManageLabTerraformStateLock"
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [local.lab_lockfile_object]
  }

  statement {
    sid    = "ReadEc2LabNetworkFoundation"
    effect = "Allow"
    actions = [
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcs",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:Region"
      values   = [var.aws_region]
    }
  }

  statement {
    sid       = "ReadLabVpcAttributes"
    effect    = "Allow"
    actions   = ["ec2:DescribeVpcAttribute"]
    resources = [local.ec2_vpc_arn]

    condition {
      test     = "StringEquals"
      variable = "ec2:Region"
      values   = [var.aws_region]
    }
  }

  statement {
    sid       = "CreateTaggedLabVpc"
    effect    = "Allow"
    actions   = ["ec2:CreateVpc"]
    resources = [local.ec2_vpc_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Project"
      values   = [var.project_name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Environment"
      values   = [local.lab_environment]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:TagKeys"
      values   = local.terraform_lab_request_tag_keys
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:Region"
      values   = [var.aws_region]
    }
  }

  statement {
    sid       = "CreateTaggedLabInternetGateway"
    effect    = "Allow"
    actions   = ["ec2:CreateInternetGateway"]
    resources = [local.ec2_internet_gateway_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Project"
      values   = [var.project_name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Environment"
      values   = [local.lab_environment]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:TagKeys"
      values   = local.terraform_lab_request_tag_keys
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:Region"
      values   = [var.aws_region]
    }
  }

  statement {
    sid       = "CreateTaggedLabSubnet"
    effect    = "Allow"
    actions   = ["ec2:CreateSubnet"]
    resources = [local.ec2_subnet_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Project"
      values   = [var.project_name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Environment"
      values   = [local.lab_environment]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:TagKeys"
      values   = local.terraform_lab_request_tag_keys
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:Region"
      values   = [var.aws_region]
    }
  }

  statement {
    sid    = "CreateLabNetworkResourcesInTaggedVpc"
    effect = "Allow"
    actions = [
      "ec2:CreateRouteTable",
      "ec2:CreateSubnet",
    ]
    resources = [local.ec2_vpc_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Project"
      values   = [var.project_name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = [local.lab_environment]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:Region"
      values   = [var.aws_region]
    }
  }

  statement {
    sid       = "CreateTaggedLabRouteTable"
    effect    = "Allow"
    actions   = ["ec2:CreateRouteTable"]
    resources = [local.ec2_route_table_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Project"
      values   = [var.project_name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Environment"
      values   = [local.lab_environment]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:TagKeys"
      values   = local.terraform_lab_request_tag_keys
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:Region"
      values   = [var.aws_region]
    }
  }

  statement {
    sid     = "TagLabNetworkResourcesOnCreate"
    effect  = "Allow"
    actions = ["ec2:CreateTags"]
    resources = [
      local.ec2_internet_gateway_arn,
      local.ec2_route_table_arn,
      local.ec2_subnet_arn,
      local.ec2_vpc_arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values = [
        "CreateInternetGateway",
        "CreateRouteTable",
        "CreateSubnet",
        "CreateVpc",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Project"
      values   = [var.project_name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Environment"
      values   = [local.lab_environment]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:TagKeys"
      values   = local.terraform_lab_request_tag_keys
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:Region"
      values   = [var.aws_region]
    }
  }

  statement {
    sid    = "ManageTaggedLabNetworkResources"
    effect = "Allow"
    actions = [
      "ec2:AttachInternetGateway",
      "ec2:CreateRoute",
      "ec2:DeleteInternetGateway",
      "ec2:DeleteRoute",
      "ec2:ReplaceRoute",
      "ec2:DetachInternetGateway",
    ]
    resources = [
      local.ec2_internet_gateway_arn,
      local.ec2_route_table_arn,
      local.ec2_vpc_arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Project"
      values   = [var.project_name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = [local.lab_environment]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:Region"
      values   = [var.aws_region]
    }
  }

  statement {
    sid    = "ManageTaggedLabRouteTableAssociationsAndSubnets"
    effect = "Allow"
    actions = [
      "ec2:AssociateRouteTable",
      "ec2:DeleteSubnet",
      "ec2:DisassociateRouteTable",
      "ec2:ModifySubnetAttribute",
      "ec2:ReplaceRouteTableAssociation",
    ]
    resources = [
      local.ec2_route_table_arn,
      local.ec2_subnet_arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Project"
      values   = [var.project_name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = [local.lab_environment]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:Region"
      values   = [var.aws_region]
    }
  }

  statement {
    sid    = "ManageTaggedLabVpcAndRouteTables"
    effect = "Allow"
    actions = [
      "ec2:DeleteRouteTable",
      "ec2:DeleteVpc",
      "ec2:ModifyVpcAttribute",
    ]
    resources = [
      local.ec2_route_table_arn,
      local.ec2_vpc_arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Project"
      values   = [var.project_name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = [local.lab_environment]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:Region"
      values   = [var.aws_region]
    }
  }

  statement {
    sid    = "UpdateMutableTagsOnTaggedLabNetworkResources"
    effect = "Allow"
    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags",
    ]
    resources = local.terraform_lab_network_resource_arns

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Project"
      values   = [var.project_name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = [local.lab_environment]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:TagKeys"
      values   = local.terraform_lab_mutable_tag_keys
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:Region"
      values   = [var.aws_region]
    }
  }
}

resource "aws_iam_policy" "terraform_lab_apply" {
  name        = local.terraform_lab_apply_policy_name
  description = "Allows Terraform applies for the environments/lab network foundation and state."
  policy      = data.aws_iam_policy_document.terraform_lab_apply.json

  tags = {
    Name = local.terraform_lab_apply_policy_name
  }
}

resource "aws_iam_role_policy_attachment" "terraform_lab_apply" {
  role       = aws_iam_role.github_actions_terraform_lab_apply.name
  policy_arn = aws_iam_policy.terraform_lab_apply.arn
}

data "aws_iam_policy_document" "terraform_lab_egress" {
  statement {
    sid    = "ReadEc2LabEgress"
    effect = "Allow"
    actions = [
      "ec2:DescribeAddresses",
      "ec2:DescribeNatGateways",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:Region"
      values   = [var.aws_region]
    }
  }

  statement {
    sid       = "AllocateTaggedLabElasticIp"
    effect    = "Allow"
    actions   = ["ec2:AllocateAddress"]
    resources = [local.ec2_elastic_ip_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Project"
      values   = [var.project_name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Environment"
      values   = [local.lab_environment]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:TagKeys"
      values   = local.terraform_lab_request_tag_keys
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:Region"
      values   = [var.aws_region]
    }
  }

  statement {
    sid       = "ReleaseTaggedLabElasticIp"
    effect    = "Allow"
    actions   = ["ec2:ReleaseAddress"]
    resources = [local.ec2_elastic_ip_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Project"
      values   = [var.project_name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = [local.lab_environment]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:Region"
      values   = [var.aws_region]
    }
  }

  statement {
    sid       = "CreateTaggedLabNatGateway"
    effect    = "Allow"
    actions   = ["ec2:CreateNatGateway"]
    resources = [local.ec2_nat_gateway_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Project"
      values   = [var.project_name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Environment"
      values   = [local.lab_environment]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:TagKeys"
      values   = local.terraform_lab_request_tag_keys
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:Region"
      values   = [var.aws_region]
    }
  }

  statement {
    sid     = "CreateLabNatGatewayInTaggedNetwork"
    effect  = "Allow"
    actions = ["ec2:CreateNatGateway"]
    resources = [
      local.ec2_elastic_ip_arn,
      local.ec2_subnet_arn,
      local.ec2_vpc_arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Project"
      values   = [var.project_name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = [local.lab_environment]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:Region"
      values   = [var.aws_region]
    }
  }

  statement {
    sid       = "DeleteTaggedLabNatGateway"
    effect    = "Allow"
    actions   = ["ec2:DeleteNatGateway"]
    resources = [local.ec2_nat_gateway_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Project"
      values   = [var.project_name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = [local.lab_environment]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:Region"
      values   = [var.aws_region]
    }
  }

  statement {
    sid     = "TagLabEgressResourcesOnCreate"
    effect  = "Allow"
    actions = ["ec2:CreateTags"]
    resources = [
      local.ec2_elastic_ip_arn,
      local.ec2_nat_gateway_arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values = [
        "AllocateAddress",
        "CreateNatGateway",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Project"
      values   = [var.project_name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Environment"
      values   = [local.lab_environment]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:TagKeys"
      values   = local.terraform_lab_request_tag_keys
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:Region"
      values   = [var.aws_region]
    }
  }

  statement {
    sid    = "UpdateMutableTagsOnTaggedLabEgressResources"
    effect = "Allow"
    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags",
    ]
    resources = local.terraform_lab_egress_resource_arns

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Project"
      values   = [var.project_name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = [local.lab_environment]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:TagKeys"
      values   = local.terraform_lab_mutable_tag_keys
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:Region"
      values   = [var.aws_region]
    }
  }
}

resource "aws_iam_policy" "terraform_lab_egress" {
  name        = local.terraform_lab_egress_policy_name
  description = "Allows Terraform applies for optional EKS NAT egress in environments/lab."
  policy      = data.aws_iam_policy_document.terraform_lab_egress.json

  tags = {
    Name = local.terraform_lab_egress_policy_name
  }
}

resource "aws_iam_role_policy_attachment" "terraform_lab_egress" {
  role       = aws_iam_role.github_actions_terraform_lab_apply.name
  policy_arn = aws_iam_policy.terraform_lab_egress.arn
}
