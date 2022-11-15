module "backend_ecs_service" {
  source = "../modules/ecs_service"

  region               = var.region
  env_name             = local.env_name
  service_name         = "backend"
  service_docker_image = "nginx:latest"
  alb                  = { instance = aws_lb.api_public, listener_arn = aws_lb_listener.api_public_alb_https.arn }
  ecs_cluster_id       = aws_ecs_cluster.app.id
  host_name            = "${local.env_name}.${var.dns_zone_name}"
}
