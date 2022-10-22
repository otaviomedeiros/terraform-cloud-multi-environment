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

resource "aws_ecr_repository" "repository" {
  name                 = "frontend-${terraform.workspace}"
  image_tag_mutability = "MUTABLE"
}