data "cloudflare_zone" "site" {
  zone_id = var.dns.zone_id
}

resource "cloudflare_record" "ephemeral_app" {
  zone_id = var.dns.zone_id
  name    = var.dns.record_name
  value   = var.dns.record_value
  type    = "CNAME"
  proxied = true
}