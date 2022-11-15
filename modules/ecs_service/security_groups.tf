resource "aws_security_group" "service" {
  name        = local.service_identifier
  description = "Allow inbound traffic from a Load Balancer"
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
    Name = "${var.env_name} - Private traffic from load balancer"
  }
}