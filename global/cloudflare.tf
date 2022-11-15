data "cloudflare_zone" "site" {
  name = var.dns_zone_name
}

resource "cloudflare_record" "dns_validation" {
  for_each = { for o in aws_acm_certificate.cert.domain_validation_options : o.domain_name => o }

  zone_id         = data.cloudflare_zone.site.zone_id
  name            = each.value.resource_record_name
  value           = each.value.resource_record_value
  type            = each.value.resource_record_type
  proxied         = false
  allow_overwrite = true
}