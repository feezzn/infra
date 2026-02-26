locals {
  alb_sa_namespace = "kube-system"
  alb_sa_name      = "aws-load-balancer-controller"
}

resource "aws_iam_policy" "alb_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/alb_iam_policy.json")
}

data "aws_iam_policy_document" "alb_irsa_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_arn, "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/", "")}:sub"
      values   = ["system:serviceaccount:${local.alb_sa_namespace}:${local.alb_sa_name}"]
    }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "alb_controller" {
  name               = "eks-alb-controller"
  assume_role_policy = data.aws_iam_policy_document.alb_irsa_assume_role.json
}

resource "aws_iam_role_policy_attachment" "alb_attach" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}

resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = local.alb_sa_name
    namespace = local.alb_sa_namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }
  }
}

resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = local.alb_sa_namespace
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  depends_on = [kubernetes_service_account.alb_controller]

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = local.alb_sa_name
  }
}