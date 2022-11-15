variable "region" {
  description = "The AWS regions in which the resources will be provisioned"
  type        = string
}

variable "cidr_block" {
  type = string
}

variable "cloudflare_api_token" {
  description = "Cloud Flare API token used to create DNS records"
  type        = string
}

variable "dns_zone_name" {
  description = "The site DNS zone name"
  type        = string
}