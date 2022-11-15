locals {
  log_group_name = "/ecs/${local.service_identifier}"
}

resource "aws_ecs_task_definition" "service" {
  family = local.service_identifier
  requires_compatibilities = [
    "FARGATE",
  ]

  execution_role_arn = aws_iam_role.task_definition.arn
  task_role_arn      = aws_iam_role.task_definition.arn

  network_mode = "awsvpc"
  cpu          = 256
  memory       = 512
  container_definitions = jsonencode([
    {
      name      = var.service_name
      image     = var.docker.image
      essential = true
      cpu       = 256
      memory    = 512
      portMappings = [
        {
          containerPort = var.docker.port
          hostPort      = var.docker.port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-region"        = var.region,
          "awslogs-group"         = local.log_group_name,
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "service" {
  name              = local.log_group_name
  retention_in_days = 30
}