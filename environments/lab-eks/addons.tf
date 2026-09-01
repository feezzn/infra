resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = aws_eks_cluster.lab.name
  addon_name   = "eks-pod-identity-agent"

  tags = {
    Name = "${local.cluster_name}-pod-identity-agent"
  }
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.lab.name
  addon_name   = "vpc-cni"

  pod_identity_association {
    service_account = "aws-node"
    role_arn        = aws_iam_role.vpc_cni.arn
  }

  tags = {
    Name = "${local.cluster_name}-vpc-cni"
  }

  depends_on = [
    aws_eks_addon.pod_identity_agent,
    aws_iam_role_policy_attachment.vpc_cni,
  ]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.lab.name
  addon_name   = "kube-proxy"

  tags = {
    Name = "${local.cluster_name}-kube-proxy"
  }

  depends_on = [
    aws_eks_node_group.default,
  ]
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.lab.name
  addon_name   = "coredns"

  tags = {
    Name = "${local.cluster_name}-coredns"
  }

  depends_on = [
    aws_eks_node_group.default,
  ]
}
