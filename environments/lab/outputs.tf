output "aws_account_id" {
  description = "AWS account ID where the lab foundation is planned."
  value       = data.aws_caller_identity.current.account_id
}

output "availability_zones" {
  description = "Availability zones selected for the lab network."
  value       = local.availability_zones
}

output "internet_gateway_id" {
  description = "ID of the lab Internet Gateway."
  value       = aws_internet_gateway.lab.id
}

output "private_subnet_ids" {
  description = "IDs of the private lab subnets."
  value       = [for key in sort(keys(aws_subnet.private)) : aws_subnet.private[key].id]
}

output "public_subnet_ids" {
  description = "IDs of the public lab subnets."
  value       = [for key in sort(keys(aws_subnet.public)) : aws_subnet.public[key].id]
}

output "vpc_cidr" {
  description = "CIDR block of the lab VPC."
  value       = aws_vpc.lab.cidr_block
}

output "vpc_id" {
  description = "ID of the lab VPC."
  value       = aws_vpc.lab.id
}
