provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.86"
    }
  }
  required_version = ">= 0.12"
  backend "s3" {
    bucket         = "portfolio-s3-backend-state-bucket"
    key            = "terraform-state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table-eks-portfolio"
    encrypt        = true
  }
}
