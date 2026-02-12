data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "jenkins_server" {
  ami                  = data.aws_ami.amazon_linux_2023.id
  instance_type        = var.jenkins_instance_type
  key_name             = var.key_name
  subnet_id            = var.public_subnet_id
  vpc_security_group_ids = [var.jenkins_sg_id]
  iam_instance_profile = var.jenkins_instance_profile

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-server"
  }
}

resource "aws_instance" "app_server" {
  ami                  = data.aws_ami.amazon_linux_2023.id
  instance_type        = var.app_instance_type
  key_name             = var.key_name
  subnet_id            = var.public_subnet_id
  vpc_security_group_ids = [var.app_sg_id]
  iam_instance_profile = var.app_instance_profile

  tags = {
    Name = "${var.project_name}-${var.environment}-app-server"
  }
}
