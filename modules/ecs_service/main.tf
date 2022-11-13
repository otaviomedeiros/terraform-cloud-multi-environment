locals {
  service_identifier = "${var.env}--${var.service_name}"
}

data "aws_iam_policy_document" "task_definition" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_definition" {
  name               = "${var.env}--task-definition-role"
  assume_role_policy = data.aws_iam_policy_document.task_definition.json
}

resource "aws_iam_role_policy_attachment" "app_tast_definition_policy" {
  role       = aws_iam_role.task_definition.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
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
      image     = var.service_docker_image
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
          "awslogs-group"         = "/ecs/${local.service_identifier}",
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "service" {
  name              = "/ecs/${local.service_identifier}"
  retention_in_days = 30
}

resource "aws_security_group" "service" {
  name        = local.service_identifier
  description = "Allow private inbound traffic"
  vpc_id      = var.alb.instance.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = var.alb.instance.security_groups
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