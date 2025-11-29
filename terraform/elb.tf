

# Target Group for the webserver instance
resource "aws_lb_target_group" "webserver" {
  name     = local.target_group_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200-302"
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  deregistration_delay = 150

  tags = {
    Name = "${var.env}-${var.project_name}-tg"
  }
}

# Listener rule to forward traffic to target group
resource "aws_lb_listener_rule" "webserver" {
  listener_arn = data.aws_lb_listener.https.arn
  priority     = local.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webserver.arn
  }

  condition {
    host_header {
      values = [var.hostname]
    }
  }

  tags = {
    Name = local.listener_rule_name
  }
}

# Attach EC2 instance to Target Group
resource "aws_lb_target_group_attachment" "webserver" {
  target_group_arn = aws_lb_target_group.webserver.arn
  target_id        = aws_instance.webserver.id
  port             = 80
}

