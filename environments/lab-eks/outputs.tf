output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.lab.name
}

output "cluster_endpoint" {
  description = "EKS Kubernetes API endpoint."
  value       = aws_eks_cluster.lab.endpoint
}

output "cluster_version" {
  description = "EKS Kubernetes version."
  value       = aws_eks_cluster.lab.version
}

output "cluster_security_group_id" {
  description = "Security group created by EKS for the cluster control plane."
  value       = aws_eks_cluster.lab.vpc_config[0].cluster_security_group_id
}

output "node_group_name" {
  description = "Managed node group name."
  value       = aws_eks_node_group.default.node_group_name
}

output "eks_admin_role_arn" {
  description = "Stable IAM role ARN for human Kubernetes administration."
  value       = aws_iam_role.eks_lab_admin.arn
}
