locals {
  environment  = "lab"
  name_prefix  = "${var.project_name}-${local.environment}-eks"
  cluster_name = local.name_prefix

  network_outputs = data.terraform_remote_state.lab_network.outputs

  vpc_id             = local.network_outputs.vpc_id
  private_subnet_ids = local.network_outputs.private_subnet_ids
  availability_zones = local.network_outputs.availability_zones

  eks_admin_trusted_principal_arn = coalesce(
    var.eks_admin_trusted_principal_arn,
    "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:user/${var.eks_admin_trusted_user_name}"
  )

  eks_cluster_admin_policy_arn = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  common_tags = {
    Project     = var.project_name
    Environment = local.environment
    Owner       = var.owner
    ManagedBy   = "Terraform"
    CostCenter  = "platform"
    Purpose     = "platform-engineering-lab"
  }
}
