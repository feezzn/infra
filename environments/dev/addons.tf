module "eks_addons" {
  source = "../../modules/eks-addons"

  cluster_name = module.eks.cluster_name
  region       = var.region
  vpc_id       = module.vpc.vpc_id

  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_issuer_url   = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}