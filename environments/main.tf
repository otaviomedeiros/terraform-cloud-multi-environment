terraform {
  backend "remote" {
    organization = "otavio-corp"

    workspaces {
      prefix = "app-"
    }
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

locals {
  env                    = terraform.workspace
  ephemeral_environments = jsondecode(file("./ephemeral-envs/${local.env}.json"))
}