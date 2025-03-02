terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.86"
    }
    # random = {
    #   source  = "hashicorp/random"
    #   version = "~> 3.6.1"
    # }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.4"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
  }
  required_version = ">= 0.12"
}
