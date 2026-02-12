output "vpc_id" {
  description = "The ID of the VPC created in the networking module"
  value       = module.networking.vpc_id
}

output "public_subnet_id" {
  description = "The ID of the public subnet created in the networking module"
  value       = module.networking.public_subnet_id
}

output "jenkins_sg_id" {
  description = "Security Group ID for Jenkins"
  value       = module.security.jenkins_sg_id
}

output "app_sg_id" {
  description = "Security Group ID for App"
  value       = module.security.app_sg_id
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "jenkins_public_ip" {
  description = "Public IP of the Jenkins Server"
  value       = module.compute.jenkins_public_ip
}

output "app_public_ip" {
  description = "Public IP of the App Server"
  value       = module.compute.app_public_ip
}
