provider "aws" {
  region = "eu-west-2"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.86"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.4"
    }
  }
  required_version = ">= 0.12"
  backend "s3" {
    bucket         = "portfolio-s3-backend-state-bucket-eu-west-2"
    key            = "terraform-state/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-lock-table-eks-portfolio"
    encrypt        = true
  }
}
