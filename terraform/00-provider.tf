provider "aws" {
  region = "eu-west-2"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 0.12"
  backend "s3" {
    bucket         = "eks-portfolio-s3-state-bucket"
    key            = "terraform-state/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-lock-table-eks-portfolio"
    encrypt        = true
  }
}