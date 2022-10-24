locals {
  service_name = "app"
}

resource "aws_ecr_repository" "repository" {
  name                 = "frontend-${local.env}"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecs_cluster" "app" {
  name = "app-ecs-cluster-${local.env}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "app" {
  cluster_name = aws_ecs_cluster.app.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

data "aws_iam_policy_document" "app_task_definition_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app_task_definition_role" {
  name               = "app-task-definition-role-${local.env}"
  assume_role_policy = data.aws_iam_policy_document.app_task_definition_role_policy.json
}

resource "aws_iam_role_policy_attachment" "app-tast-definition-policy" {
  role       = aws_iam_role.app_task_definition_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "app_task_definition" {
  family = "app-task-definition-${local.env}"
  requires_compatibilities = [
    "FARGATE",
  ]

  execution_role_arn = aws_iam_role.app_task_definition_role.arn
  task_role_arn      = aws_iam_role.app_task_definition_role.arn

  network_mode = "awsvpc"
  cpu          = 256
  memory       = 512
  container_definitions = jsonencode([
    {
      name      = "app-task-definition"
      image     = "nginx:latest"
      essential = true
      cpu       = 256
      memory    = 512
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-region"        = var.region,
          "awslogs-group"         = "/ecs/${local.service_name}-${local.env}",
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "service" {
  name              = "/ecs/${local.service_name}-${local.env}"
  retention_in_days = 30
}

resource "aws_security_group" "service" {
  name        = "app_service_sg-${local.env}"
  description = "Allow private inbound traffic"
  vpc_id      = aws_lb.public.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = aws_lb.public.security_groups
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "App VPC - Private traffic from load balancer"
  }
}

resource "aws_ecs_service" "app" {
  name                               = local.service_name
  cluster                            = aws_ecs_cluster.app.id
  task_definition                    = aws_ecs_task_definition.app_task_definition.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    security_groups  = [aws_security_group.service.id]
    subnets          = aws_lb.public.subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.public_alb.arn
    container_name   = "app-task-definition"
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
