# --- Security Groups ---
resource "aws_security_group" "alb_sg" {
  name        = "${var.service_name}-alb-sg"
  description = var.alb_sg_description
  vpc_id      = aws_vpc.ecs_dev_vpc.id

  ingress {
    from_port   = var.alb_http_port
    to_port     = var.alb_http_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_http_cidrs
  }

  ingress {
    from_port   = var.alb_https_port
    to_port     = var.alb_https_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_https_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.allowed_egress_cidrs
  }

  tags = {
    Name        = "${var.service_name}-alb-sg"
    Environment = var.environment
  }
}

# --- Security Group for ECS Tasks ---
resource "aws_security_group" "ecs_task_sg" {
  name        = "${var.service_name}-task-sg"
  description = var.ecs_task_sg_description
  vpc_id      = aws_vpc.ecs_dev_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.allowed_egress_cidrs
  }

  ingress {
    description     = var.ecs_task_ingress_description
    from_port       = var.ecs_container_port
    to_port         = var.ecs_container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  tags = {
    Name        = "${var.service_name}-task-sg"
    Environment = var.environment
  }
}