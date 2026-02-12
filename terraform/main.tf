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
