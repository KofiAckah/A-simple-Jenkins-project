terraform {
  backend "s3" {
    bucket  = "terraform-state-management-a-simple-jenkins-project"
    key     = "terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}