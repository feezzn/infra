resource "aws_eks_access_entry" "lab_admin" {
  cluster_name  = aws_eks_cluster.lab.name
  principal_arn = aws_iam_role.eks_lab_admin.arn
  type          = "STANDARD"

  tags = {
    Name = var.eks_admin_role_name
  }
}

resource "aws_eks_access_policy_association" "lab_admin_cluster_admin" {
  cluster_name  = aws_eks_cluster.lab.name
  principal_arn = aws_iam_role.eks_lab_admin.arn
  policy_arn    = local.eks_cluster_admin_policy_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.lab_admin,
  ]
}
