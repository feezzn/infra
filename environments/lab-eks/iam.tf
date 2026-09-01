data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    sid     = "AllowEksServiceAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  name               = "${local.name_prefix}-cluster"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json

  tags = {
    Name = "${local.name_prefix}-cluster"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    sid     = "AllowEc2AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node" {
  name               = "${local.name_prefix}-node"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json

  tags = {
    Name = "${local.name_prefix}-node"
  }
}

resource "aws_iam_role_policy_attachment" "eks_node_worker" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_ecr_pull_only" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

data "aws_iam_policy_document" "vpc_cni_assume_role" {
  statement {
    sid    = "AllowEksPodsAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "vpc_cni" {
  name               = "${local.name_prefix}-vpc-cni"
  assume_role_policy = data.aws_iam_policy_document.vpc_cni_assume_role.json

  tags = {
    Name = "${local.name_prefix}-vpc-cni"
  }
}

resource "aws_iam_role_policy_attachment" "vpc_cni" {
  role       = aws_iam_role.vpc_cni.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy"
}

data "aws_iam_policy_document" "eks_lab_admin_assume_role" {
  statement {
    sid     = "AllowHumanAdminAssumeRoleWithMfa"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [local.eks_admin_trusted_principal_arn]
    }

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

resource "aws_iam_role" "eks_lab_admin" {
  name                 = var.eks_admin_role_name
  assume_role_policy   = data.aws_iam_policy_document.eks_lab_admin_assume_role.json
  max_session_duration = 3600

  tags = {
    Name = var.eks_admin_role_name
  }
}

data "aws_iam_policy_document" "eks_lab_admin_describe_cluster" {
  statement {
    sid       = "AllowDescribeLabEksCluster"
    effect    = "Allow"
    actions   = ["eks:DescribeCluster"]
    resources = [aws_eks_cluster.lab.arn]
  }
}

resource "aws_iam_policy" "eks_lab_admin_describe_cluster" {
  name        = "${local.name_prefix}-admin-describe-cluster"
  description = "Allows the human lab admin role to build kubeconfig for the lab EKS cluster."
  policy      = data.aws_iam_policy_document.eks_lab_admin_describe_cluster.json

  tags = {
    Name = "${local.name_prefix}-admin-describe-cluster"
  }
}

resource "aws_iam_role_policy_attachment" "eks_lab_admin_describe_cluster" {
  role       = aws_iam_role.eks_lab_admin.name
  policy_arn = aws_iam_policy.eks_lab_admin_describe_cluster.arn
}
