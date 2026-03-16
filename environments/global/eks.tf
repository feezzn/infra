# EKS Cluster Module (COMMENTED)
# Uncomment after you:
# 1. Define if global needs its own EKS or shares dev/prod
# 2. Update principal_arn and cluster name for global environment
# 3. Use module.vpc.private_subnet_ids from VPC module outputs

# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "~> 21.0"
#
#   name               = "global-eks"
#   kubernetes_version = "1.34"
#
#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = module.vpc.private_subnet_ids
#
#   addons = {
#     vpc-cni = {
#       before_compute              = true
#       most_recent                 = true
#       resolve_conflicts_on_create = "OVERWRITE"
#       resolve_conflicts_on_update = "OVERWRITE"
#     }
#     kube-proxy = {
#       before_compute              = true
#       most_recent                 = true
#       resolve_conflicts_on_create = "OVERWRITE"
#       resolve_conflicts_on_update = "OVERWRITE"
#     }
#     coredns = {
#       before_compute              = true
#       most_recent                 = true
#       resolve_conflicts_on_create = "OVERWRITE"
#       resolve_conflicts_on_update = "OVERWRITE"
#     }
#   }
#
#   endpoint_private_access      = true
#   endpoint_public_access       = false
#
#   access_entries = {
#     cluster_creator = {
#       principal_arn = "arn:aws:iam::GLOBAL_ACCOUNT_ID:role/global-iac-role"
#       policy_associations = {
#         admin = {
#           policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
#           access_scope = { type = "cluster" }
#         }
#       }
#     }
#   }
#
#   eks_managed_node_groups = {
#     default = {
#       name           = "global-eks"
#       instance_types = ["t3.medium"]
#
#       min_size     = 1
#       max_size     = 3
#       desired_size = 1
#
#       subnet_ids = module.vpc.private_subnet_ids
#
#       metadata_options = {
#         http_endpoint = "enabled"
#         http_tokens   = "required"
#       }
#       iam_role_additional_policies = {
#         AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#       }
#     }
#   }
#
#   enable_cluster_creator_admin_permissions = true
#
#   tags = {
#     Environment = "global"
#     Project     = "infra-iac"
#   }
# }