module "networking" {
  source = "./networking"

  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  project_name       = var.project_name
  environment        = var.environment
}

module "security" {
  source = "./security"

  vpc_id         = module.networking.vpc_id
  ssh_allowed_ip = var.ssh_allowed_ip
  project_name   = var.project_name
  environment    = var.environment
}

module "ecr" {
  source = "./ecr"

  project_name = var.project_name
  environment  = var.environment
}

module "compute" {
  source = "./compute"

  project_name             = var.project_name
  environment              = var.environment
  jenkins_instance_type    = var.jenkins_instance_type
  app_instance_type        = var.app_instance_type
  key_name                 = var.key_name
  public_subnet_id         = module.networking.public_subnet_id
  jenkins_sg_id            = module.security.jenkins_sg_id
  app_sg_id                = module.security.app_sg_id
  jenkins_instance_profile = module.security.jenkins_profile_name
  app_instance_profile     = module.security.app_profile_name
}

resource "local_file" "ansible_inventory" {
  content = <<EOT
[jenkins_server]
${module.compute.jenkins_public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=./${var.key_name}.pem

[app_server]
${module.compute.app_public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=./${var.key_name}.pem

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOT
  filename = "../ansible/inventory.ini"
}