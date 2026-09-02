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

  terraform_lab_eks_plan_role_name                = "github-actions-terraform-lab-eks-plan"
  terraform_lab_eks_apply_role_name               = "github-actions-terraform-lab-eks-apply"
  terraform_lab_eks_plan_state_policy_name        = "github-actions-terraform-lab-eks-plan-state"
  terraform_lab_eks_apply_state_policy_name       = "github-actions-terraform-lab-eks-apply-state"
  terraform_lab_eks_read_policy_name              = "github-actions-terraform-lab-eks-read"
  terraform_lab_eks_apply_eks_cluster_policy_name = "github-actions-terraform-lab-eks-apply-eks-cluster"
  terraform_lab_eks_apply_eks_addons_policy_name  = "github-actions-terraform-lab-eks-apply-eks-addons"
  terraform_lab_eks_apply_eks_access_policy_name  = "github-actions-terraform-lab-eks-apply-eks-access"
  terraform_lab_eks_apply_eks_tags_policy_name    = "github-actions-terraform-lab-eks-apply-eks-tags"
  terraform_lab_eks_apply_iam_roles_policy_name   = "github-actions-terraform-lab-eks-apply-iam-roles"
  terraform_lab_eks_apply_iam_policy_name         = "github-actions-terraform-lab-eks-apply-iam-policies"
  terraform_lab_eks_apply_passrole_policy_name    = "github-actions-terraform-lab-eks-apply-passrole"

  lab_environment                     = "lab"
  github_oidc_lab_environment_subject = "repo:${local.github_repository_full_name}:environment:${local.lab_environment}"
  lab_state_key                       = "environments/lab/terraform.tfstate"
  lab_lockfile_key                    = "${local.lab_state_key}.tflock"
  lab_state_object                    = "${local.state_bucket_arn}/${local.lab_state_key}"
  lab_lockfile_object                 = "${local.state_bucket_arn}/${local.lab_lockfile_key}"
  lab_eks_state_key                   = "environments/lab-eks/terraform.tfstate"
  lab_eks_lockfile_key                = "${local.lab_eks_state_key}.tflock"
  lab_eks_state_object                = "${local.state_bucket_arn}/${local.lab_eks_state_key}"
  lab_eks_lockfile_object             = "${local.state_bucket_arn}/${local.lab_eks_lockfile_key}"

  lab_eks_cluster_name               = "${var.project_name}-${local.lab_environment}-eks"
  lab_eks_node_group_name            = "${local.lab_eks_cluster_name}-default"
  lab_eks_cluster_role_name          = "${local.lab_eks_cluster_name}-cluster"
  lab_eks_node_role_name             = "${local.lab_eks_cluster_name}-node"
  lab_eks_vpc_cni_role_name          = "${local.lab_eks_cluster_name}-vpc-cni"
  lab_eks_admin_role_name            = "eks-lab-admin"
  lab_eks_admin_describe_policy_name = "${local.lab_eks_cluster_name}-admin-describe-cluster"
  lab_eks_kubernetes_version         = "1.36"
  lab_eks_cluster_admin_policy_arn   = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  lab_eks_cluster_managed_policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSClusterPolicy"
  lab_eks_node_worker_policy_arn     = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  lab_eks_node_ecr_pull_policy_arn   = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  lab_eks_vpc_cni_managed_policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy"
  lab_eks_cluster_role_arn           = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${local.lab_eks_cluster_role_name}"
  lab_eks_node_role_arn              = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${local.lab_eks_node_role_name}"
  lab_eks_vpc_cni_role_arn           = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${local.lab_eks_vpc_cni_role_name}"
  lab_eks_admin_role_arn             = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${local.lab_eks_admin_role_name}"
  lab_eks_admin_describe_policy_arn  = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:policy/${local.lab_eks_admin_describe_policy_name}"
  lab_eks_cluster_arn                = "arn:${data.aws_partition.current.partition}:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${local.lab_eks_cluster_name}"
  lab_eks_node_group_arn             = "arn:${data.aws_partition.current.partition}:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:nodegroup/${local.lab_eks_cluster_name}/${local.lab_eks_node_group_name}/*"
  lab_eks_admin_access_entry_arn     = "arn:${data.aws_partition.current.partition}:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:access-entry/${local.lab_eks_cluster_name}/role/${data.aws_caller_identity.current.account_id}/${local.lab_eks_admin_role_name}/*"
  lab_eks_pod_identity_arn           = "arn:${data.aws_partition.current.partition}:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:podidentityassociation/${local.lab_eks_cluster_name}/*"

  lab_eks_addon_names = [
    "coredns",
    "eks-pod-identity-agent",
    "kube-proxy",
    "vpc-cni",
  ]

  lab_eks_addon_arns = [
    for addon_name in local.lab_eks_addon_names :
    "arn:${data.aws_partition.current.partition}:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:addon/${local.lab_eks_cluster_name}/${addon_name}/*"
  ]

  lab_eks_eks_resource_arns = concat(
    [
      local.lab_eks_admin_access_entry_arn,
      local.lab_eks_cluster_arn,
      local.lab_eks_node_group_arn,
      local.lab_eks_pod_identity_arn,
    ],
    local.lab_eks_addon_arns
  )

  lab_eks_iam_role_arns = [
    local.lab_eks_admin_role_arn,
    local.lab_eks_cluster_role_arn,
    local.lab_eks_node_role_arn,
    local.lab_eks_vpc_cni_role_arn,
  ]

  lab_eks_managed_policy_arns = [
    local.lab_eks_cluster_managed_policy_arn,
    local.lab_eks_node_worker_policy_arn,
    local.lab_eks_node_ecr_pull_policy_arn,
    local.lab_eks_vpc_cni_managed_policy_arn,
  ]

  lab_eks_iam_policy_arns = [
    local.lab_eks_admin_describe_policy_arn,
  ]

  lab_eks_role_attachment_policy_arns = concat(
    local.lab_eks_managed_policy_arns,
    local.lab_eks_iam_policy_arns
  )

  lab_eks_service_linked_role_arns = [
    "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/eks-nodegroup.amazonaws.com/AWSServiceRoleForAmazonEKSNodegroup",
    "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/eks.amazonaws.com/AWSServiceRoleForAmazonEKS",
  ]

  lab_eks_request_tag_keys = [
    "CostCenter",
    "Environment",
    "ManagedBy",
    "Name",
    "Owner",
    "Project",
    "Purpose",
  ]

  lab_eks_mutable_tag_keys = [
    "CostCenter",
    "ManagedBy",
    "Name",
    "Owner",
    "Purpose",
  ]

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
      "ec2:DescribeAddressesAttribute",
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

data "aws_iam_policy_document" "github_actions_terraform_lab_eks_plan_assume_role" {
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

resource "aws_iam_role" "github_actions_terraform_lab_eks_plan" {
  name               = local.terraform_lab_eks_plan_role_name
  description        = "GitHub Actions role for read-only Terraform plans in environments/lab-eks."
  assume_role_policy = data.aws_iam_policy_document.github_actions_terraform_lab_eks_plan_assume_role.json

  tags = {
    Name = local.terraform_lab_eks_plan_role_name
  }
}

data "aws_iam_policy_document" "github_actions_terraform_lab_eks_apply_assume_role" {
  statement {
    sid     = "AllowGitHubActionsLabEnvironment"
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

resource "aws_iam_role" "github_actions_terraform_lab_eks_apply" {
  name               = local.terraform_lab_eks_apply_role_name
  description        = "GitHub Actions role for applying Terraform changes in environments/lab-eks."
  assume_role_policy = data.aws_iam_policy_document.github_actions_terraform_lab_eks_apply_assume_role.json

  tags = {
    Name = local.terraform_lab_eks_apply_role_name
  }
}

data "aws_iam_policy_document" "terraform_lab_eks_plan_state" {
  statement {
    sid       = "ListLabEksAndNetworkTerraformStates"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.state_bucket_arn]

    condition {
      test     = "StringEquals"
      variable = "s3:prefix"
      values = [
        local.lab_eks_state_key,
        local.lab_state_key,
      ]
    }
  }

  statement {
    sid     = "ReadLabEksAndNetworkTerraformStates"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      local.lab_eks_state_object,
      local.lab_state_object,
    ]
  }
}

resource "aws_iam_policy" "terraform_lab_eks_plan_state" {
  name        = local.terraform_lab_eks_plan_state_policy_name
  description = "Allows read-only Terraform state access for environments/lab-eks plans."
  policy      = data.aws_iam_policy_document.terraform_lab_eks_plan_state.json

  tags = {
    Name = local.terraform_lab_eks_plan_state_policy_name
  }
}

resource "aws_iam_role_policy_attachment" "terraform_lab_eks_plan_state" {
  role       = aws_iam_role.github_actions_terraform_lab_eks_plan.name
  policy_arn = aws_iam_policy.terraform_lab_eks_plan_state.arn
}

data "aws_iam_policy_document" "terraform_lab_eks_apply_state" {
  statement {
    sid       = "ListLabEksAndNetworkTerraformStates"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.state_bucket_arn]

    condition {
      test     = "StringEquals"
      variable = "s3:prefix"
      values = [
        local.lab_eks_lockfile_key,
        local.lab_eks_state_key,
        local.lab_state_key,
      ]
    }
  }

  statement {
    sid     = "ReadNetworkTerraformState"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      local.lab_state_object,
    ]
  }

  statement {
    sid    = "ReadWriteLabEksTerraformState"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [
      local.lab_eks_state_object,
    ]
  }

  statement {
    sid    = "ManageLabEksTerraformStateLock"
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [
      local.lab_eks_lockfile_object,
    ]
  }
}

resource "aws_iam_policy" "terraform_lab_eks_apply_state" {
  name        = local.terraform_lab_eks_apply_state_policy_name
  description = "Allows Terraform state and lockfile access for environments/lab-eks applies."
  policy      = data.aws_iam_policy_document.terraform_lab_eks_apply_state.json

  tags = {
    Name = local.terraform_lab_eks_apply_state_policy_name
  }
}

resource "aws_iam_role_policy_attachment" "terraform_lab_eks_apply_state" {
  role       = aws_iam_role.github_actions_terraform_lab_eks_apply.name
  policy_arn = aws_iam_policy.terraform_lab_eks_apply_state.arn
}

data "aws_iam_policy_document" "terraform_lab_eks_read" {
  statement {
    sid       = "ReadCallerIdentity"
    effect    = "Allow"
    actions   = ["sts:GetCallerIdentity"]
    resources = ["*"]
  }

  statement {
    sid    = "ReadEc2Dependencies"
    effect = "Allow"
    actions = [
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
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
    sid    = "ReadGlobalEksMetadata"
    effect = "Allow"
    actions = [
      "eks:DescribeAddonConfiguration",
      "eks:DescribeAddonVersions",
      "eks:DescribeClusterVersions",
      "eks:ListAccessPolicies",
      "eks:ListClusters",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }

  statement {
    sid    = "ReadLabEksCluster"
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:DescribeUpdate",
      "eks:ListAccessEntries",
      "eks:ListAddons",
      "eks:ListNodegroups",
      "eks:ListPodIdentityAssociations",
      "eks:ListTagsForResource",
      "eks:ListUpdates",
    ]
    resources = [local.lab_eks_cluster_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }

  statement {
    sid    = "ReadLabEksAccessEntry"
    effect = "Allow"
    actions = [
      "eks:DescribeAccessEntry",
      "eks:ListAssociatedAccessPolicies",
      "eks:ListTagsForResource",
    ]
    resources = [local.lab_eks_admin_access_entry_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }

  statement {
    sid    = "ReadLabEksAddons"
    effect = "Allow"
    actions = [
      "eks:DescribeAddon",
      "eks:DescribeUpdate",
      "eks:ListTagsForResource",
      "eks:ListUpdates",
    ]
    resources = local.lab_eks_addon_arns

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }

  statement {
    sid    = "ReadLabEksNodeGroup"
    effect = "Allow"
    actions = [
      "eks:DescribeNodegroup",
      "eks:DescribeUpdate",
      "eks:ListTagsForResource",
      "eks:ListUpdates",
    ]
    resources = [local.lab_eks_node_group_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }

  statement {
    sid    = "ReadLabEksPodIdentityAssociation"
    effect = "Allow"
    actions = [
      "eks:DescribePodIdentityAssociation",
      "eks:ListTagsForResource",
    ]
    resources = [local.lab_eks_pod_identity_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }

  statement {
    sid    = "ReadLabEksIamRoles"
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:ListAttachedRolePolicies",
      "iam:ListRoleTags",
    ]
    resources = local.lab_eks_iam_role_arns
  }

  statement {
    sid    = "ReadLabEksIamPolicies"
    effect = "Allow"
    actions = [
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListEntitiesForPolicy",
      "iam:ListPolicyTags",
      "iam:ListPolicyVersions",
    ]
    resources = local.lab_eks_role_attachment_policy_arns
  }
}

resource "aws_iam_policy" "terraform_lab_eks_read" {
  name        = local.terraform_lab_eks_read_policy_name
  description = "Allows read-only AWS refresh and plan access for environments/lab-eks."
  policy      = data.aws_iam_policy_document.terraform_lab_eks_read.json

  tags = {
    Name = local.terraform_lab_eks_read_policy_name
  }
}

resource "aws_iam_role_policy_attachment" "terraform_lab_eks_plan_read" {
  role       = aws_iam_role.github_actions_terraform_lab_eks_plan.name
  policy_arn = aws_iam_policy.terraform_lab_eks_read.arn
}

resource "aws_iam_role_policy_attachment" "terraform_lab_eks_apply_read" {
  role       = aws_iam_role.github_actions_terraform_lab_eks_apply.name
  policy_arn = aws_iam_policy.terraform_lab_eks_read.arn
}

data "aws_iam_policy_document" "terraform_lab_eks_apply_eks_cluster" {
  statement {
    sid       = "CreateTaggedLabEksCluster"
    effect    = "Allow"
    actions   = ["eks:CreateCluster"]
    resources = ["*"]

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
      values   = local.lab_eks_request_tag_keys
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }

    condition {
      test     = "StringEquals"
      variable = "eks:authenticationMode"
      values   = ["API"]
    }

    condition {
      test     = "StringEquals"
      variable = "eks:kubernetesVersion"
      values   = [local.lab_eks_kubernetes_version]
    }

    condition {
      test     = "StringEquals"
      variable = "eks:supportType"
      values   = ["STANDARD"]
    }

    condition {
      test     = "Bool"
      variable = "eks:bootstrapClusterCreatorAdminPermissions"
      values   = ["false"]
    }

    condition {
      test     = "Bool"
      variable = "eks:bootstrapSelfManagedAddons"
      values   = ["false"]
    }

    condition {
      test     = "Bool"
      variable = "eks:endpointPrivateAccess"
      values   = ["true"]
    }

    condition {
      test     = "Bool"
      variable = "eks:endpointPublicAccess"
      values   = ["true"]
    }
  }

  statement {
    sid       = "CreateTaggedLabEksNodeGroup"
    effect    = "Allow"
    actions   = ["eks:CreateNodegroup"]
    resources = [local.lab_eks_cluster_arn]

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
      values   = local.lab_eks_request_tag_keys
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }

  statement {
    sid    = "ManageTaggedLabEksCluster"
    effect = "Allow"
    actions = [
      "eks:DeleteCluster",
      "eks:UpdateClusterConfig",
      "eks:UpdateClusterVersion",
    ]
    resources = [local.lab_eks_cluster_arn]

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
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }

  statement {
    sid    = "ManageTaggedLabEksNodeGroup"
    effect = "Allow"
    actions = [
      "eks:DeleteNodegroup",
      "eks:UpdateNodegroupConfig",
      "eks:UpdateNodegroupVersion",
    ]
    resources = [local.lab_eks_node_group_arn]

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
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }
}

data "aws_iam_policy_document" "terraform_lab_eks_apply_eks_addons" {
  statement {
    sid       = "CreateTaggedLabEksAddons"
    effect    = "Allow"
    actions   = ["eks:CreateAddon"]
    resources = [local.lab_eks_cluster_arn]

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
      values   = local.lab_eks_request_tag_keys
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }

  statement {
    sid       = "CreateLabEksAddonPodIdentityAssociation"
    effect    = "Allow"
    actions   = ["eks:CreatePodIdentityAssociation"]
    resources = [local.lab_eks_cluster_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }

  statement {
    sid    = "ManageLabEksAddonPodIdentityAssociation"
    effect = "Allow"
    actions = [
      "eks:CreateAddon",
      "eks:DeleteAddon",
      "eks:UpdateAddon",
    ]
    resources = [local.lab_eks_pod_identity_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }

  statement {
    sid    = "ManageTaggedLabEksAddons"
    effect = "Allow"
    actions = [
      "eks:DeleteAddon",
      "eks:UpdateAddon",
    ]
    resources = local.lab_eks_addon_arns

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
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }

}

data "aws_iam_policy_document" "terraform_lab_eks_apply_eks_access" {
  statement {
    sid       = "CreateTaggedLabEksAccessEntry"
    effect    = "Allow"
    actions   = ["eks:CreateAccessEntry"]
    resources = [local.lab_eks_cluster_arn]

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
      variable = "aws:RequestTag/Project"
      values   = [var.project_name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Environment"
      values   = [local.lab_environment]
    }

    condition {
      test     = "StringEquals"
      variable = "eks:accessEntryType"
      values   = ["STANDARD"]
    }

    condition {
      test     = "StringEquals"
      variable = "eks:principalArn"
      values   = [local.lab_eks_admin_role_arn]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:TagKeys"
      values   = local.lab_eks_request_tag_keys
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }

  statement {
    sid    = "ManageTaggedLabEksAccessEntry"
    effect = "Allow"
    actions = [
      "eks:DeleteAccessEntry",
      "eks:DisassociateAccessPolicy",
      "eks:UpdateAccessEntry",
    ]
    resources = [local.lab_eks_admin_access_entry_arn]

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
      variable = "eks:clusterName"
      values   = [local.lab_eks_cluster_name]
    }

    condition {
      test     = "StringEquals"
      variable = "eks:principalArn"
      values   = [local.lab_eks_admin_role_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }

  statement {
    sid       = "AssociateLabEksAdminAccessPolicy"
    effect    = "Allow"
    actions   = ["eks:AssociateAccessPolicy"]
    resources = [local.lab_eks_admin_access_entry_arn]

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
      variable = "eks:accessScope"
      values   = ["cluster"]
    }

    condition {
      test     = "StringEquals"
      variable = "eks:clusterName"
      values   = [local.lab_eks_cluster_name]
    }

    condition {
      test     = "StringEquals"
      variable = "eks:policyArn"
      values   = [local.lab_eks_cluster_admin_policy_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "eks:principalArn"
      values   = [local.lab_eks_admin_role_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }
}

data "aws_iam_policy_document" "terraform_lab_eks_apply_eks_tags" {
  statement {
    sid       = "TagLabEksResourcesWithRequiredTags"
    effect    = "Allow"
    actions   = ["eks:TagResource"]
    resources = local.lab_eks_eks_resource_arns

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
      values   = local.lab_eks_request_tag_keys
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }

  statement {
    sid    = "UpdateMutableTagsOnTaggedLabEksResources"
    effect = "Allow"
    actions = [
      "eks:TagResource",
      "eks:UntagResource",
    ]
    resources = local.lab_eks_eks_resource_arns

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
      values   = local.lab_eks_mutable_tag_keys
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }
}

resource "aws_iam_policy" "terraform_lab_eks_apply_eks_cluster" {
  name        = local.terraform_lab_eks_apply_eks_cluster_policy_name
  description = "Allows Terraform to manage only the lab EKS cluster and managed node group."
  policy      = data.aws_iam_policy_document.terraform_lab_eks_apply_eks_cluster.json

  tags = {
    Name = local.terraform_lab_eks_apply_eks_cluster_policy_name
  }
}

resource "aws_iam_role_policy_attachment" "terraform_lab_eks_apply_eks_cluster" {
  role       = aws_iam_role.github_actions_terraform_lab_eks_apply.name
  policy_arn = aws_iam_policy.terraform_lab_eks_apply_eks_cluster.arn
}

resource "aws_iam_policy" "terraform_lab_eks_apply_eks_addons" {
  name        = local.terraform_lab_eks_apply_eks_addons_policy_name
  description = "Allows Terraform to manage only the lab EKS add-ons and pod identity associations."
  policy      = data.aws_iam_policy_document.terraform_lab_eks_apply_eks_addons.json

  tags = {
    Name = local.terraform_lab_eks_apply_eks_addons_policy_name
  }
}

resource "aws_iam_role_policy_attachment" "terraform_lab_eks_apply_eks_addons" {
  role       = aws_iam_role.github_actions_terraform_lab_eks_apply.name
  policy_arn = aws_iam_policy.terraform_lab_eks_apply_eks_addons.arn
}

resource "aws_iam_policy" "terraform_lab_eks_apply_eks_access" {
  name        = local.terraform_lab_eks_apply_eks_access_policy_name
  description = "Allows Terraform to manage only the lab EKS access entry and access policy association."
  policy      = data.aws_iam_policy_document.terraform_lab_eks_apply_eks_access.json

  tags = {
    Name = local.terraform_lab_eks_apply_eks_access_policy_name
  }
}

resource "aws_iam_role_policy_attachment" "terraform_lab_eks_apply_eks_access" {
  role       = aws_iam_role.github_actions_terraform_lab_eks_apply.name
  policy_arn = aws_iam_policy.terraform_lab_eks_apply_eks_access.arn
}

resource "aws_iam_policy" "terraform_lab_eks_apply_eks_tags" {
  name        = local.terraform_lab_eks_apply_eks_tags_policy_name
  description = "Allows Terraform to tag lab EKS resources while keeping Project and Environment immutable after creation."
  policy      = data.aws_iam_policy_document.terraform_lab_eks_apply_eks_tags.json

  tags = {
    Name = local.terraform_lab_eks_apply_eks_tags_policy_name
  }
}

resource "aws_iam_role_policy_attachment" "terraform_lab_eks_apply_eks_tags" {
  role       = aws_iam_role.github_actions_terraform_lab_eks_apply.name
  policy_arn = aws_iam_policy.terraform_lab_eks_apply_eks_tags.arn
}

data "aws_iam_policy_document" "terraform_lab_eks_apply_iam_roles" {
  statement {
    sid       = "CreateTaggedLabEksIamRoles"
    effect    = "Allow"
    actions   = ["iam:CreateRole"]
    resources = local.lab_eks_iam_role_arns

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
      values   = local.lab_eks_request_tag_keys
    }
  }

  statement {
    sid       = "TagLabEksIamRolesWithRequiredTags"
    effect    = "Allow"
    actions   = ["iam:TagRole"]
    resources = local.lab_eks_iam_role_arns

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
      values   = local.lab_eks_request_tag_keys
    }
  }

  statement {
    sid       = "ReadLabEksIamRoleInlinePolicies"
    effect    = "Allow"
    actions   = ["iam:ListRolePolicies"]
    resources = local.lab_eks_iam_role_arns
  }

  statement {
    sid    = "ManageTaggedLabEksIamRoles"
    effect = "Allow"
    actions = [
      "iam:DeleteRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateRole",
      "iam:UpdateRoleDescription",
    ]
    resources = local.lab_eks_iam_role_arns

    condition {
      test     = "StringEquals"
      variable = "iam:ResourceTag/Project"
      values   = [var.project_name]
    }

    condition {
      test     = "StringEquals"
      variable = "iam:ResourceTag/Environment"
      values   = [local.lab_environment]
    }
  }

  statement {
    sid    = "UpdateMutableTagsOnTaggedLabEksIamRoles"
    effect = "Allow"
    actions = [
      "iam:TagRole",
      "iam:UntagRole",
    ]
    resources = local.lab_eks_iam_role_arns

    condition {
      test     = "StringEquals"
      variable = "iam:ResourceTag/Project"
      values   = [var.project_name]
    }

    condition {
      test     = "StringEquals"
      variable = "iam:ResourceTag/Environment"
      values   = [local.lab_environment]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:TagKeys"
      values   = local.lab_eks_mutable_tag_keys
    }
  }
}

data "aws_iam_policy_document" "terraform_lab_eks_apply_iam_policies" {
  statement {
    sid       = "CreateTaggedLabEksIamPolicies"
    effect    = "Allow"
    actions   = ["iam:CreatePolicy"]
    resources = local.lab_eks_iam_policy_arns

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
      values   = local.lab_eks_request_tag_keys
    }
  }

  statement {
    sid       = "TagLabEksIamPoliciesWithRequiredTags"
    effect    = "Allow"
    actions   = ["iam:TagPolicy"]
    resources = local.lab_eks_iam_policy_arns

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
      values   = local.lab_eks_request_tag_keys
    }
  }

  statement {
    sid    = "ManageTaggedLabEksIamPolicyVersions"
    effect = "Allow"
    actions = [
      "iam:CreatePolicyVersion",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:SetDefaultPolicyVersion",
    ]
    resources = local.lab_eks_iam_policy_arns

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
  }

  statement {
    sid    = "UpdateMutableTagsOnTaggedLabEksIamPolicies"
    effect = "Allow"
    actions = [
      "iam:TagPolicy",
      "iam:UntagPolicy",
    ]
    resources = local.lab_eks_iam_policy_arns

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
      values   = local.lab_eks_mutable_tag_keys
    }
  }

  statement {
    sid    = "AttachExpectedPoliciesToTaggedLabEksRoles"
    effect = "Allow"
    actions = [
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
    ]
    resources = local.lab_eks_iam_role_arns

    condition {
      test     = "StringEquals"
      variable = "iam:PolicyARN"
      values   = local.lab_eks_role_attachment_policy_arns
    }

    condition {
      test     = "StringEquals"
      variable = "iam:ResourceTag/Project"
      values   = [var.project_name]
    }

    condition {
      test     = "StringEquals"
      variable = "iam:ResourceTag/Environment"
      values   = [local.lab_environment]
    }
  }
}

data "aws_iam_policy_document" "terraform_lab_eks_apply_passrole" {
  statement {
    sid     = "PassLabEksRolesToEksService"
    effect  = "Allow"
    actions = ["iam:PassRole"]
    resources = [
      local.lab_eks_cluster_role_arn,
      local.lab_eks_node_role_arn,
      local.lab_eks_vpc_cni_role_arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["eks.amazonaws.com"]
    }
  }

  statement {
    sid       = "PassLabEksVpcCniRoleToPodIdentity"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [local.lab_eks_vpc_cni_role_arn]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["pods.eks.amazonaws.com"]
    }
  }

  statement {
    sid       = "CreateEksServiceLinkedRolesIfMissing"
    effect    = "Allow"
    actions   = ["iam:CreateServiceLinkedRole"]
    resources = local.lab_eks_service_linked_role_arns

    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values = [
        "eks-nodegroup.amazonaws.com",
        "eks.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "terraform_lab_eks_apply_iam_roles" {
  name        = local.terraform_lab_eks_apply_iam_roles_policy_name
  description = "Allows Terraform to manage only the IAM roles required by environments/lab-eks."
  policy      = data.aws_iam_policy_document.terraform_lab_eks_apply_iam_roles.json

  tags = {
    Name = local.terraform_lab_eks_apply_iam_roles_policy_name
  }
}

resource "aws_iam_role_policy_attachment" "terraform_lab_eks_apply_iam_roles" {
  role       = aws_iam_role.github_actions_terraform_lab_eks_apply.name
  policy_arn = aws_iam_policy.terraform_lab_eks_apply_iam_roles.arn
}

resource "aws_iam_policy" "terraform_lab_eks_apply_iam_policies" {
  name        = local.terraform_lab_eks_apply_iam_policy_name
  description = "Allows Terraform to manage only the IAM policies and role attachments required by environments/lab-eks."
  policy      = data.aws_iam_policy_document.terraform_lab_eks_apply_iam_policies.json

  tags = {
    Name = local.terraform_lab_eks_apply_iam_policy_name
  }
}

resource "aws_iam_role_policy_attachment" "terraform_lab_eks_apply_iam_policies" {
  role       = aws_iam_role.github_actions_terraform_lab_eks_apply.name
  policy_arn = aws_iam_policy.terraform_lab_eks_apply_iam_policies.arn
}

resource "aws_iam_policy" "terraform_lab_eks_apply_passrole" {
  name        = local.terraform_lab_eks_apply_passrole_policy_name
  description = "Allows Terraform to pass only the lab EKS roles to the required AWS services."
  policy      = data.aws_iam_policy_document.terraform_lab_eks_apply_passrole.json

  tags = {
    Name = local.terraform_lab_eks_apply_passrole_policy_name
  }
}

resource "aws_iam_role_policy_attachment" "terraform_lab_eks_apply_passrole" {
  role       = aws_iam_role.github_actions_terraform_lab_eks_apply.name
  policy_arn = aws_iam_policy.terraform_lab_eks_apply_passrole.arn
}
