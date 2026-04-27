terraform {
  backend "s3" {
    bucket         = "terraform-state-project2-srujana"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

module "infrastructure" {
  source            = "../../modules/infrastructure"
  environment       = "dev"
  vpc_cidr          = var.vpc_cidr
  subnet_cidr       = var.subnet_cidr
  availability_zone = var.availability_zone
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  key_name          = var.key_name
  aws_region        = var.aws_region
  private_ip        = "10.0.1.10"
}