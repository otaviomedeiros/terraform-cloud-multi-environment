module "backend_ecs_service" {
  source = "../ecs_service"

  region               = var.region
  env                  = local.ephemeral_env_identifier
  service_name         = "backend"
  service_docker_image = "httpd:latest"
  alb                  = var.alb
  ecs_cluster_id       = var.ecs_cluster_id
  host_name            = "${var.ephemeral_env_name}.${data.cloudflare_zone.site.name}"
}
