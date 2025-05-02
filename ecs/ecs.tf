# --- ECS Defination ---
resource "aws_ecs_cluster" "main_cluster" {
  name = var.ecs_cluster_name
  configuration {
    execute_command_configuration {
      logging = var.ecs_execute_command_logging
      log_configuration {
        # Reference the name of the log group you created
        cloud_watch_log_group_name = aws_cloudwatch_log_group.execute_command_logs.name

        # Or use the variable directly if you prefer (ensure it matches the log group name)
        # cloud_watch_log_group_name = var.ecs_execute_command_log_group_name

        # Optionally add:
        # cloud_watch_encryption_enabled = true

        # Or configure S3 logging instead:
        # s3_bucket_name = var.ecs_execute_command_s3_bucket
        # s3_key_prefix  = var.ecs_execute_command_s3_prefix
        # s3_encryption_enabled = true
      }
    }
  }

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights
  }

  tags = {
    Environment = var.environment
  }

}

# --- CloudWatch Log Group for Execute Command ---
resource "aws_cloudwatch_log_group" "execute_command_logs" {
  name              = var.ecs_execute_command_log_group_name
  retention_in_days = 14 # Adjust as needed
  tags = {
    Environment = var.environment
  }
}

# --- CloudWatch Log Group for Container Logs ---
resource "aws_cloudwatch_log_group" "container_logs" {
  # Use the name specified by the variable that the task definition uses
  name              = var.log_group_name
  retention_in_days = 30 # Adjust retention as needed

  tags = merge(
    var.common_tags,
    {
      Name    = var.log_group_name # Tag with the same name
      Purpose = "ECS Container Logs"
    }
  )
}

# --- ECS Task Execution IAM Role ---
# This role is assumed by the ECS agent to manage tasks (pull images, write logs, etc.)
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.task_definition_family}-execution-role"

  # Trust policy allowing ECS tasks to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.task_definition_family}-execution-role"
    }
  )
}

# Attach the standard AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = var.ecs_task_execution_policy_arn
}


# --- ECS Task IAM Role ---
# This role is assumed by the containers within your task to interact with other AWS services.
# Attach specific policies based on what your application needs (e.g., S3 access, DynamoDB access).

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.task_definition_family}-task-role"

  # Trust policy allowing ECS tasks to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.task_definition_family}-task-role"
    }
  )
}

# --- Example: Attach a custom policy (Optional) ---
# Create or reference an IAM policy granting permissions your app needs
# resource "aws_iam_policy" "app_permissions" {
#   name        = "${var.task_definition_family}-app-policy"
#   description = "Permissions required by the application container"
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "s3:GetObject",
#           "dynamodb:Query"
#         ]
#         Effect   = "Allow"
#         Resource = "*" # IMPORTANT: Scope this down to specific resources!
#       },
#     ]
#   })
# }
#
# resource "aws_iam_role_policy_attachment" "ecs_task_role_app_policy" {
#   role       = aws_iam_role.ecs_task_role.name
#   policy_arn = aws_iam_policy.app_permissions.arn
# }

# --- ECS Cluster Capacity provider Definition ---
resource "aws_ecs_cluster_capacity_providers" "main_cluster_providers" {
  cluster_name       = aws_ecs_cluster.main_cluster.name
  capacity_providers = var.capacity_providers

  default_capacity_provider_strategy {
    capacity_provider = var.default_capacity_provider_strategy[0].capacity_provider
    weight            = var.default_capacity_provider_strategy[0].weight
    base              = var.default_capacity_provider_strategy[0].base
  }

  default_capacity_provider_strategy {
    capacity_provider = var.default_capacity_provider_strategy[1].capacity_provider
    weight            = var.default_capacity_provider_strategy[1].weight
    base              = var.default_capacity_provider_strategy[1].base
  }
}

# --- ECS Task Definition Resource ---
resource "aws_ecs_task_definition" "app_task_def" {
  family                   = var.task_definition_family
  requires_compatibilities = [var.requires_compatibility]
  network_mode             = var.networkmode
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  runtime_platform {
    operating_system_family = var.task_os_family
    cpu_architecture        = var.task_cpu_architecture
  }

  # --- Container Definition(s) ---
  container_definitions = jsonencode([
    {
      name              = var.container_name
      image             = var.container_image
      cpu               = var.container_cpu
      memory            = var.container_allocate_memory
      memoryReservation = var.container_reserved_memory
      essential         = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      # --- CloudWatch Log configuration --- 
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = var.log_stream_prefix
        }
      }

    }
  ])

  tags = merge(
    var.common_tags,
    {
      Name = "${var.task_definition_family}-task-def"
    }
  )
  # Explicit dependency can help, though often inferred
  depends_on = [
    aws_iam_role.ecs_task_role,
    aws_iam_role.ecs_task_execution_role,
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy,
  ]
}

# --- ECS Service Definition ---
# This resource runs and maintains your task definition on the cluster
resource "aws_ecs_service" "main_app_service" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.main_cluster.arn
  task_definition = aws_ecs_task_definition.app_task_def.arn
  desired_count   = var.ecs_service_desired_count
  launch_type     = var.ecs_service_launch_type

  network_configuration {
    subnets = [
      aws_subnet.private_subnet_1.id,
      aws_subnet.private_subnet_2.id
    ]
    security_groups  = [aws_security_group.ecs_task_sg.id]
    assign_public_ip = var.ecs_service_assign_public_ip
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.my_app_tg.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
  health_check_grace_period_seconds = 60

  depends_on = [
    aws_ecs_task_definition.app_task_def,
    aws_subnet.private_subnet_1,
    aws_subnet.private_subnet_2,
    aws_security_group.ecs_task_sg,
    aws_lb_target_group.my_app_tg,
  ]

  tags = merge(
    var.common_tags,
    { Name = var.ecs_service_name }
  )
}

# --- ECS Task Resource (Example for one-off tasks) ---
# This resource runs individual instances of a task definition.
# Suitable for batch jobs, scheduled tasks, or tasks run directly by Terraform.
# It does NOT provide self-healing or load balancing like aws_ecs_service.

# resource "aws_ecs_t" "my_batch_job" {
#   cluster         = aws_ecs_cluster.main_cluster.arn
#   task_definition = aws_ecs_task_definition.app_task_def.arn
#   launch_type     = "FARGATE"
#   count           = 1 

#   network_configuration {
#     subnets = [
#       aws_subnet.private_subnet_1.id,
#       aws_subnet.private_subnet_2.id
#     ]
#     security_groups = [aws_security_group.ecs_task_sg.id]

#     assign_public_ip = false
#   }

#   # Optional: Override container commands or environment variables
#   # overrides {
#   #   container_overrides {
#   #     name        = var.container_name
#   #     command     = ["/app/run_batch_script.sh", "--input", "data.csv"]
#   #     environment = [
#   #       { name = "BATCH_ID", value = "run-${timestamp()}" }
#   #     ]
#   #   }
#   # }

#   tags = merge(
#     var.common_tags,
#     { Name = "ecs-development-job-task" } # Specific name for this task run
#   )
#   depends_on = [
#     aws_ecs_task_definition.app_task_def,
#     aws_subnet.private_subnet_1,
#     aws_subnet.private_subnet_2,
#     aws_security_group.ecs_task_sg,
#   ]
# }