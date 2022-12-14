locals {
  public_api_domain_name = local.env_name
}

data "cloudflare_zone" "site" {
  name = var.dns_zone_name
}

resource "cloudflare_record" "public_api" {
  zone_id = data.cloudflare_zone.site.zone_id
  name    = local.public_api_domain_name
  value   = aws_lb.api_public.dns_name
  type    = "CNAME"
  proxied = true
}
