terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-stable-diffusion-state"
    key            = "poc/stable-diffusion/dev/us-east-1/terraform.tfstate"
    kms_key_id     = "alias/dev-terraform-bucket-state"
    dynamodb_table = "stable_diffusion_dev_terraform_lock_table"
    region         = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  vpc_id          = var.vpc_id
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  name            = var.name
  environment     = var.environment
}

