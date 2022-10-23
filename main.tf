terraform {
  backend "remote" {
    organization = "otavio-corp"

    workspaces {
      prefix = "app-"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}
