module "ephemeral_env" {
  for_each = { for environment in local.ephemeral_environments : environment.name => environment }
  source   = "./modules/ephemeral_env"

  region         = var.region
  env            = local.env
  ephemeral_env  = each.value.name
  ecs_cluster_id = aws_ecs_cluster.app.id

  alb = {
    instance     = aws_lb.api_public,
    listener_arn = aws_lb_listener.api_public_alb_https.arn
  }

  dns = {
    zone_id      = data.cloudflare_zone.site.zone_id
    record_name  = each.value.name
    record_value = aws_lb.api_public.dns_name
  }
}