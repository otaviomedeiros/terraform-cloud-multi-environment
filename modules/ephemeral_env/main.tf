terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

locals {
  ephemeral_env_identifier = "${var.env_name}-${var.ephemeral_env_name}"
}