terraform {
  backend "remote" {
    organization = "otavio-corp"

    workspaces {
      prefix = "beta"
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
  elastic_env_name = "app-dev" # this may be passed as argument
  ephemeral_env_name = terraform.workspace
}

data "cloudflare_zone" "site" {
  name = var.domain_dns_name
}

data "aws_ecs_cluster" "services" {
  cluster_name = "${local.elastic_env_name}--cluster"
}

data "aws_lb" "public_api" {
  name = "${local.elastic_env_name}--api--public-alb"
}

data "aws_lb_listener" "secure" {
  load_balancer_arn = data.aws_lb.public_api.arn
  port              = 443
}

module "ephemeral_env" {
  source = "../../modules/ephemeral_env"

  region         = var.region
  env            = local.elastic_env_name
  ephemeral_env  = local.ephemeral_env_name
  ecs_cluster_id = data.aws_ecs_cluster.services.id

  alb = {
    instance     = data.aws_lb.public_api,
    listener_arn = data.aws_lb_listener.secure.arn
  }

  dns = {
    zone_id      = data.cloudflare_zone.site.zone_id
    record_name  = local.ephemeral_env_name
    record_value = data.aws_lb.public_api.dns_name
  }
}