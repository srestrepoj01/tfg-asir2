resource "aws_lb" "mastodon" {
  name               = "mastodon-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_id]
  subnets            = var.public_subnet_ids

  tags = {
    Name    = "${var.project_name}-alb"
    Project = var.project_name
  }
}

# Grupo objetivo del servicio web (puerto 3000)
resource "aws_lb_target_group" "mastodon_web_tg" {
  name        = "mastodon-web-targets"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  
  health_check {
    enabled             = true
    interval            = 30
    path                = "/health"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    matcher             = "200"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400  # 24 horas en segundos
    enabled         = true
  }

  tags = {
    Name    = "${var.project_name}-web-tg"
    Project = var.project_name
  }
}

# Grupo objetivo del servicio de streaming (puerto 4000)
resource "aws_lb_target_group" "mastodon_streaming_tg" {
  name        = "mastodon-streaming-targets"
  port        = 4000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  
  health_check {
    enabled             = true
    interval            = 30
    path                = "/api/v1/streaming/health"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    matcher             = "200-399"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400  # 24 horas en segundos
    enabled         = true
  }

  tags = {
    Name    = "${var.project_name}-streaming-tg"
    Project = var.project_name
  }
}

# Listener HTTP principal
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.mastodon.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mastodon_web_tg.arn
  }
}

# Regla para la API de streaming
resource "aws_lb_listener_rule" "streaming" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mastodon_streaming_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/v1/streaming/*"]
    }
  }
}

resource "aws_lb_target_group_attachment" "web_attachment" {
  for_each = toset(var.ec2_instance_ids)

  target_group_arn = aws_lb_target_group.mastodon_web_tg.arn
  target_id        = each.value
  port             = 3000
}

resource "aws_lb_target_group_attachment" "streaming_attachment" {
  for_each = toset(var.ec2_instance_ids)

  target_group_arn = aws_lb_target_group.mastodon_streaming_tg.arn
  target_id        = each.value
  port             = 4000
}

output "lb_arn_suffix" {
  description = "El sufijo ARN del balanceador de carga"
  value       = aws_lb.mastodon.arn_suffix
}

output "target_group_web_arn_suffix" {
  description = "El sufijo ARN del grupo objetivo web"
  value       = aws_lb_target_group.mastodon_web_tg.arn_suffix
}

output "target_group_streaming_arn_suffix" {
  description = "El sufijo ARN del grupo objetivo de streaming"
  value       = aws_lb_target_group.mastodon_streaming_tg.arn_suffix
}