resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.lab.name
  node_group_name = "${local.cluster_name}-default"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = local.private_subnet_ids
  version         = var.kubernetes_version

  capacity_type  = "ON_DEMAND"
  instance_types = var.node_instance_types

  scaling_config {
    desired_size = var.node_group_desired_size
    min_size     = var.node_group_min_size
    max_size     = var.node_group_max_size
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name = "${local.cluster_name}-default"
  }

  depends_on = [
    aws_eks_addon.vpc_cni,
    aws_iam_role_policy_attachment.eks_node_ecr_pull_only,
    aws_iam_role_policy_attachment.eks_node_worker,
  ]
}
