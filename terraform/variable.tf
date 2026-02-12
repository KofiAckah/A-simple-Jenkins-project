# --- General Config ---
variable "aws_region" {
  description = "AWS Region to deploy resources (e.g., eu-west-1)"
  type        = string
}

variable "project_name" {
  description = "Project name prefix for tagging resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, stage, prod)"
  type        = string
}

# --- Networking ---
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

# --- Security ---
variable "ssh_allowed_ip" {
  description = "The single IP address (CIDR) allowed to SSH into instances. Use 0.0.0.0/0 for open access."
  type        = string
}

# --- Compute ---
variable "jenkins_instance_type" {
  description = "Instance type for Jenkins Server (Recommended: t3.medium)"
  type        = string
}

variable "app_instance_type" {
  description = "Instance type for Application Server (Recommended: t3.micro)"
  type        = string
}

variable "key_name" {
  description = "Name of the existing EC2 Key Pair in AWS"
  type        = string
}