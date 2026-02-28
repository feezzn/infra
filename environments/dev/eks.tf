module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "dev-eks"
  kubernetes_version = "1.34" # (lembra: upgrade minor step-by-step)

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids # ou suas subnet ids

  addons = {
    vpc-cni = {
      before_compute              = true
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    kube-proxy = {
      before_compute              = true
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    coredns = {
      before_compute              = true
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
  }


  endpoint_private_access      = true
  endpoint_public_access       = true
  endpoint_public_access_cidrs = ["0.0.0.0/0"]

  access_entries = {
    cluster_creator = {
      principal_arn = "arn:aws:iam::660830512266:role/iac-infra"
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }

    svc_admin = {
      principal_arn = "arn:aws:iam::660830512266:user/svc_admin"
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
  }

  eks_managed_node_groups = {
    default = {
      name           = "dev-eks"
      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 2

      subnet_ids = [
        "subnet-09c1b57ce0a14dc7f",
        "subnet-0df829e79822258e3"
      ]

      metadata_options = {
        http_endpoint = "enabled"
        http_tokens   = "optional" # depois você pode endurecer pra "required"
      }
      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "dev"
    Project     = "infra-iac"
  }
}