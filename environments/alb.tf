locals {
  public_api_name = "public-api-alb-${local.env_name}"
}

resource "aws_security_group" "api_public_alb" {
  name        = local.public_api_name
  description = "Allow public inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.env_name} - Public traffic SG"
  }
}

resource "aws_lb" "api_public" {
  name               = local.public_api_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.api_public_alb.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  tags = {
    Environment = "${local.env_name}"
  }
}

data "aws_acm_certificate" "cert" {
  domain   = "*.${var.dns_zone_name}"
  statuses = ["ISSUED"]
}

resource "aws_lb_listener" "api_public_alb_https" {
  load_balancer_arn = aws_lb.api_public.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.cert.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "404"
    }
  }
}
