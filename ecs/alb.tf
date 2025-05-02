
# --- Application Load Balancer (ALB) ---
resource "aws_lb" "main_alb" {
  name                       = "${var.service_name}-alb"
  internal                   = var.alb_internal
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  enable_deletion_protection = var.enable_alb_deletion_protection

  tags = {
    Name        = "${var.service_name}-alb"
    Environment = var.environment
  }
}


# --- ALB Target Group ---
resource "aws_lb_target_group" "my_app_tg" {
  name        = "${var.service_name}-tg"
  port        = var.tg_port
  protocol    = var.tg_protocol
  vpc_id      = aws_vpc.ecs_dev_vpc.id
  target_type = var.tg_target_type

  health_check {
    enabled             = var.tg_health_check_enabled
    interval            = var.tg_health_check_interval
    path                = var.tg_health_check_path
    port                = var.tg_health_check_port
    protocol            = var.tg_health_check_protocol
    timeout             = var.tg_health_check_timeout
    healthy_threshold   = var.tg_health_check_healthy_threshold
    unhealthy_threshold = var.tg_health_check_unhealthy_threshold
    matcher             = var.tg_health_check_matcher
  }

  tags = {
    Name        = "${var.service_name}-tg"
    Environment = var.environment
  }
}


# --- ALB Listener ---
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.main_alb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = var.listener_default_action_type
    target_group_arn = aws_lb_target_group.my_app_tg.arn
  }
}


# Optional: Add an HTTPS listener if you have a certificate
# resource "aws_lb_listener" "https_listener" {
#   load_balancer_arn = aws_lb.main_alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08" # Choose appropriate policy
#   certificate_arn   = var.certificate_arn # ARN of your ACM certificate
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.my_app_tg.arn
#   }
# }
