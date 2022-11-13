resource "aws_lb_target_group" "service" {
  name                 = substr(local.service_identifier, 0, 32)
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.alb.instance.vpc_id
  target_type          = "ip"
  deregistration_delay = 60
}

resource "aws_lb_listener_rule" "service_by_host" {
  listener_arn = var.alb.listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service.arn
  }

  condition {
    host_header {
      values = ["${var.host_name}"]
    }
  }
}