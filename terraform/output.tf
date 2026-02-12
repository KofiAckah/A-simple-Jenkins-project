output "vpc_id" {
  description = "The ID of the VPC created in the networking module"
  value       = module.networking.vpc_id
}

output "public_subnet_id" {
  description = "The ID of the public subnet created in the networking module"
  value       = module.networking.public_subnet_id
}
