# EKS Cluster Module (COMMENTED)
# Uncomment after you:
# 1. Ensure VPC is provisioned in prod account
# 2. Update principal_arn and cluster name for prod environment
# 3. Use module.vpc.private_subnet_ids from VPC module outputs

# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "~> 21.0"
#
#   name               = "prod-eks"
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
#   endpoint_public_access_cidrs = []
#
#   access_entries = {
#     cluster_creator = {
#       principal_arn = "arn:aws:iam::PROD_ACCOUNT_ID:role/prod-iac-role"
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
#       name           = "prod-eks"
#       instance_types = ["t3.medium"]
#
#       min_size     = 2
#       max_size     = 5
#       desired_size = 2
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
#     Environment = "prod"
#     Project     = "infra-iac"
#   }
# }