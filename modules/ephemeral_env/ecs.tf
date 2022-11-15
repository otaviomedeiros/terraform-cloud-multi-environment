module "backend_ecs_service" {
  source = "../ecs_service"

  region         = var.region
  env_name       = local.ephemeral_env_identifier
  service_name   = "backend"
  docker         = { image = "httpd:latest", port : 80 }
  alb            = var.alb
  ecs_cluster_id = var.ecs_cluster_id
  host_name      = "${var.ephemeral_env_name}.${data.cloudflare_zone.site.name}"
}
