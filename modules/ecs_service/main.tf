locals {
  service_identifier = "${var.service_name}-${var.env_name}"
}

resource "aws_ecs_service" "backend" {
  name                               = local.service_identifier
  cluster                            = var.ecs_cluster_id
  task_definition                    = aws_ecs_task_definition.service.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    security_groups  = [aws_security_group.service.id]
    subnets          = var.alb.instance.subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.service.arn
    container_name   = var.service_name
    container_port   = 80
  }

  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE"
    weight            = 100
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
}