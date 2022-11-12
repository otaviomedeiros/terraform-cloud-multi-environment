data "cloudflare_zone" "site" {
  name = var.domain_dns_name
}

resource "cloudflare_record" "app" {
  zone_id = data.cloudflare_zone.site.zone_id
  name    = local.env
  value   = aws_lb.public.dns_name
  type    = "CNAME"
  proxied = true
}
