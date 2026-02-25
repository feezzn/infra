output "prod_vpc_id" {
  value = module.vpc.vpc_id
}

output "prod_public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "prod_private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}