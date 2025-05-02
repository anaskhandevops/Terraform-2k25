# # --- Aws Provider Defination ---
# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
# }

# provider "aws" {
#   region = var.aws_region
# }


# # --- Data Sources Defination---
# data "aws_region" "current" {}

# data "aws_service_discovery_http_namespace" "namespace" {
#   name = var.namespace_name
# }


# # --- VPC Creation ---
# resource "aws_vpc" "ecs_dev_vpc" {
#   cidr_block           = var.vpc_cidr_block
#   enable_dns_support   = var.enable_dns_support
#   enable_dns_hostnames = var.enable_dns_hostnames

#   tags = {
#     Name        = var.vpc_name_tag
#     Environment = var.environment
#   }
# }


# # --- Public Subnets ---
# resource "aws_subnet" "public_subnet_1" {
#   vpc_id                  = aws_vpc.ecs_dev_vpc.id
#   cidr_block              = var.public_subnet_cidr_blocks[0]
#   availability_zone       = var.availability_zones[0]
#   map_public_ip_on_launch = var.map_public_ip_on_launch
#   tags = {
#     Name        = var.public_subnet_names[0]
#     Tier        = "Public"
#     Environment = var.environment
#   }
# }

# resource "aws_subnet" "public_subnet_2" {
#   vpc_id                  = aws_vpc.ecs_dev_vpc.id
#   cidr_block              = var.public_subnet_cidr_blocks[1]
#   availability_zone       = var.availability_zones[1]
#   map_public_ip_on_launch = var.map_public_ip_on_launch
#   tags = {
#     Name        = var.public_subnet_names[0]
#     Tier        = "Public"
#     Environment = var.environment
#   }
# }

# # --- Private Subnets ---
# resource "aws_subnet" "private_subnet_1" {
#   vpc_id            = aws_vpc.ecs_dev_vpc.id
#   cidr_block        = var.private_subnet_cidr_blocks[0]
#   availability_zone = var.availability_zones[2]
#   tags = {
#     Name        = var.private_subnet_names[0]
#     Tier        = "Private"
#     Environment = var.environment
#   }
# }

# resource "aws_subnet" "private_subnet_2" {
#   vpc_id            = aws_vpc.ecs_dev_vpc.id
#   cidr_block        = var.private_subnet_cidr_blocks[1]
#   availability_zone = var.availability_zones[1]
#   tags = {
#     Name        = var.private_subnet_names[1]
#     Tier        = "Private"
#     Environment = var.environment
#   }
# }

# # --- Internet Gateway ---
# resource "aws_internet_gateway" "gw" {
#   vpc_id = aws_vpc.ecs_dev_vpc.id

#   tags = {
#     Name        = var.internet_gateway_name
#     Environment = var.environment
#   }
# }

# # --- Elastic IP and NAT Gateway ---
# resource "aws_eip" "nat_eip" {
#   depends_on = [aws_internet_gateway.gw]

#   tags = {
#     Name        = var.nat_eip_name
#     Environment = var.environment
#   }
# }

# resource "aws_nat_gateway" "nat_gw" {
#   allocation_id = aws_eip.nat_eip.id
#   subnet_id     = aws_subnet.public_subnet_1.id

#   tags = {
#     Name        = var.nat_gateway_name
#     Environment = var.environment
#   }

#   depends_on = [aws_eip.nat_eip]
# }


# # --- Route Tables ---
# # Public Route Table
# resource "aws_route_table" "public_rt" {
#   vpc_id = aws_vpc.ecs_dev_vpc.id

#   route {
#     cidr_block = var.public_route_cidr_block
#     gateway_id = aws_internet_gateway.gw.id
#   }

#   tags = {
#     Name        = var.public_route_table_name
#     Environment = var.environment
#   }
# }

# resource "aws_route_table_association" "public_assoc_1" {
#   subnet_id      = aws_subnet.public_subnet_1.id
#   route_table_id = aws_route_table.public_rt.id
# }

# resource "aws_route_table_association" "public_assoc_2" {
#   subnet_id      = aws_subnet.public_subnet_2.id
#   route_table_id = aws_route_table.public_rt.id
# }

# # Private Route Table
# resource "aws_route_table" "private_rt" {
#   vpc_id = aws_vpc.ecs_dev_vpc.id

#   route {
#     cidr_block     = var.private_route_cidr_block
#     nat_gateway_id = aws_nat_gateway.nat_gw.id
#   }

#   tags = {
#     Name        = var.private_route_table_name
#     Environment = var.environment
#   }
# }

# resource "aws_route_table_association" "private_assoc_1" {
#   subnet_id      = aws_subnet.private_subnet_1.id
#   route_table_id = aws_route_table.private_rt.id
# }

# resource "aws_route_table_association" "private_assoc_2" {
#   subnet_id      = aws_subnet.private_subnet_2.id
#   route_table_id = aws_route_table.private_rt.id
# }

# # --- Security Groups ---
# resource "aws_security_group" "alb_sg" {
#   name        = "${var.service_name}-alb-sg"
#   description = var.alb_sg_description
#   vpc_id      = aws_vpc.ecs_dev_vpc.id

#   ingress {
#     from_port   = var.alb_http_port
#     to_port     = var.alb_http_port
#     protocol    = "tcp"
#     cidr_blocks = var.allowed_http_cidrs
#   }

#   ingress {
#     from_port   = var.alb_https_port
#     to_port     = var.alb_https_port
#     protocol    = "tcp"
#     cidr_blocks = var.allowed_https_cidrs
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = var.allowed_egress_cidrs
#   }

#   tags = {
#     Name        = "${var.service_name}-alb-sg"
#     Environment = var.environment
#   }
# }

# # --- Security Group for ECS Tasks ---
# resource "aws_security_group" "ecs_task_sg" {
#   name        = "${var.service_name}-task-sg"
#   description = var.ecs_task_sg_description
#   vpc_id      = aws_vpc.ecs_dev_vpc.id

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = var.allowed_egress_cidrs
#   }

#   ingress {
#     description     = var.ecs_task_ingress_description
#     from_port       = var.ecs_container_port
#     to_port         = var.ecs_container_port
#     protocol        = "tcp"
#     security_groups = [aws_security_group.alb_sg.id]
#   }

#   tags = {
#     Name        = "${var.service_name}-task-sg"
#     Environment = var.environment
#   }
# }

# # --- Application Load Balancer (ALB) ---
# resource "aws_lb" "main_alb" {
#   name                       = "${var.service_name}-alb"
#   internal                   = var.alb_internal
#   load_balancer_type         = "application"
#   security_groups            = [aws_security_group.alb_sg.id]
#   subnets                    = var.alb_subnets
#   enable_deletion_protection = var.enable_alb_deletion_protection

#   tags = {
#     Name        = "${var.service_name}-alb"
#     Environment = var.environment
#   }
# }


# # --- ALB Target Group ---
# resource "aws_lb_target_group" "my_app_tg" {
#   name        = "${var.service_name}-tg"
#   port        = var.tg_port
#   protocol    = var.tg_protocol
#   vpc_id      = aws_vpc.ecs_dev_vpc.id
#   target_type = var.tg_target_type

#   health_check {
#     enabled             = var.tg_health_check_enabled
#     interval            = var.tg_health_check_interval
#     path                = var.tg_health_check_path
#     port                = var.tg_health_check_port
#     protocol            = var.tg_health_check_protocol
#     timeout             = var.tg_health_check_timeout
#     healthy_threshold   = var.tg_health_check_healthy_threshold
#     unhealthy_threshold = var.tg_health_check_unhealthy_threshold
#     matcher             = var.tg_health_check_matcher
#   }

#   tags = {
#     Name        = "${var.service_name}-tg"
#     Environment = var.environment
#   }
# }


# # --- ALB Listener ---
# resource "aws_lb_listener" "http_listener" {
#   load_balancer_arn = aws_lb.main_alb.arn
#   port              = var.listener_port
#   protocol          = var.listener_protocol

#   default_action {
#     type             = var.listener_default_action_type
#     target_group_arn = aws_lb_target_group.my_app_tg.arn
#   }
# }

# # --- ECS Cluster ---
# resource "aws_ecs_cluster" "cluster_name" {
#   name = var.ecs_cluster_name

#   setting {
#     name  = "containerInsights"
#     value = var.ecs_container_insights
#   }

#   service_connect_defaults {
#     namespace = data.aws_service_discovery_http_namespace.namespace.arn
#   }

#   configuration {
#     execute_command_configuration {
#       logging = var.ecs_execute_command_logging
#     }
#   }

#   tags = {
#     Name        = var.ecs_cluster_name
#     Environment = var.environment
#   }
# }

# resource "aws_ecs_cluster_capacity_providers" "cluster_association" {
#   cluster_name       = var.cluster_name
#   capacity_providers = var.capacity_providers

#   default_capacity_provider_strategy {
#     base              = var.default_capacity_provider_strategy[0].base
#     weight            = var.default_capacity_provider_strategy[0].weight
#     capacity_provider = var.default_capacity_provider_strategy[0].capacity_provider
#   }

#   default_capacity_provider_strategy {
#     base              = var.default_capacity_provider_strategy[1].base
#     weight            = var.default_capacity_provider_strategy[1].weight
#     capacity_provider = var.default_capacity_provider_strategy[1].capacity_provider
#   }
# }

# # --- IAM Role for Task Execution ---
# resource "aws_iam_role" "ecs_task_execution_role" {
#   name = var.ecs_task_execution_role_name
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action    = "sts:AssumeRole"
#       Effect    = "Allow"
#       Principal = { Service = "ecs-tasks.amazonaws.com" }
#     }]
#   })
#   tags = {
#     Name        = var.ecs_task_execution_role_name
#     Environment = var.environment
#   }
# }

# resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy_attachment" {
#   role       = aws_iam_role.ecs_task_execution_role.name
#   policy_arn = var.ecs_task_execution_policy_arn
# }

# # --- CloudWatch Log Group ---
# resource "aws_cloudwatch_log_group" "ecs_log_group" {
#   name = "/ecs/${var.service_name}"
#   tags = {
#     Name        = "${var.service_name}-ecs-logs"
#     Environment = var.environment
#   }
# }


# # --- ECS Task Definition ---
# resource "aws_ecs_task_definition" "my_app_task" {
#   family                   = var.ecs_task_definition_family
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   cpu                      = var.ecs_task_cpu
#   memory                   = var.ecs_task_memory
#   execution_role_arn       = "arn:aws:iam::532199187081:role/ecsTaskExecutionRole"

#   container_definitions = jsonencode([{
#     name      = "my-app-container"
#     image     = var.container_image
#     essential = true
#     portMappings = [{
#       containerPort = 80
#       hostPort      = 80
#       protocol      = "tcp"
#     }]
#     logConfiguration = {
#       logDriver = "awslogs"
#       options = {
#         "awslogs-group"         = aws_cloudwatch_log_group.ecs_log_group.name
#         "awslogs-region"        = data.aws_region.current.name
#         "awslogs-stream-prefix" = "ecs"
#       }
#     }
#   }])
#   tags = {
#     Name        = "my-app-task-definition"
#     Environment = var.environment
#   }
# }

# # --- ECS Service Definition (Updated) ---
# resource "aws_ecs_service" "my_app_service" {
#   name            = var.service_name
#   cluster         = aws_ecs_cluster.cluster_name.id
#   task_definition = aws_ecs_task_definition.my_app_task.arn
#   # desired_count is now managed by Auto Scaling, but required initially
#   desired_count = var.ecs_service_min_tasks # Start with the minimum number of tasks
#   launch_type   = "FARGATE"

#   # --- Network Configuration ---
#   network_configuration {
#     subnets = [
#       aws_subnet.private_subnet_1.id,
#       aws_subnet.private_subnet_2.id
#     ]
#     security_groups  = [aws_security_group.ecs_task_sg.id]
#     assign_public_ip = false
#   }

#   placement_constraints {
#     type = "distinctInstance"
#   }

#   # --- Load Balancer Configuration (Enabled) ---
#   load_balancer {
#     target_group_arn = aws_lb_target_group.my_app_tg.arn
#     container_name   = "my-app-container" # Must match name in container_definitions
#     container_port   = 80                 # Must match containerPort in container_definitions
#   }

#   # Prevent Terraform from managing desired_count after initial creation
#   # because Auto Scaling will take over.
#   lifecycle {
#     ignore_changes = [desired_count]
#   }

#   # Ensure service waits for dependencies
#   depends_on = [
#     aws_lb_listener.http_listener, # Wait for the listener to be ready
#     aws_ecs_cluster_capacity_providers.cluster_association,
#     aws_ecs_task_definition.my_app_task,
#     aws_cloudwatch_log_group.ecs_log_group,
#     aws_nat_gateway.nat_gw,
#     aws_security_group.ecs_task_sg
#   ]

#   tags = {
#     Name        = var.service_name
#     Environment = var.environment
#     TaskGroup   = var.task_group_name
#   }
# }

# # --- ECS Service Auto Scaling ---

# # Define the scalable target (the ECS service)
# resource "aws_appautoscaling_target" "ecs_service_scaling_target" {
#   max_capacity       = var.ecs_service_max_tasks
#   min_capacity       = var.ecs_service_min_tasks
#   resource_id        = "service/${aws_ecs_cluster.cluster_name.name}/${aws_ecs_service.my_app_service.name}"
#   scalable_dimension = "ecs:service:DesiredCount"
#   service_namespace  = "ecs"

#   # Depends on the service being created
#   depends_on = [aws_ecs_service.my_app_service]
# }

# # Define the scaling policy (based on ALB Request Count Per Target) - UPDATED
# resource "aws_appautoscaling_policy" "ecs_service_requests_scaling_policy" {
#   name               = "${var.service_name}-requests-scaling-policy" # Updated name
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.ecs_service_scaling_target.resource_id
#   scalable_dimension = aws_appautoscaling_target.ecs_service_scaling_target.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.ecs_service_scaling_target.service_namespace

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ALBRequestCountPerTarget"
#       # Required label identifying the ALB Target Group
#       resource_label = "${aws_lb.main_alb.arn_suffix}/${aws_lb_target_group.my_app_tg.arn_suffix}"
#     }
#     target_value       = var.ecs_service_scale_requests_target # Target requests/target from variable
#     scale_in_cooldown  = 300                                   # Seconds before allowing another scale-in (optional)
#     scale_out_cooldown = 60                                    # Seconds before allowing another scale-out (optional)
#   }

#   # Depends on the scaling target being created
#   depends_on = [aws_appautoscaling_target.ecs_service_scaling_target]
# }






























# # # --- Namespace Defination ---
# # data "aws_service_discovery_http_namespace" "namespace" {
# #   # Look up the namespace using the name provided in the variable
# #   name = var.namespace_name
# # }

# # # --- AWS ECS Cluster Definition (Fargate Focused) ---
# # resource "aws_ecs_cluster" "cluster_name" {
# #   name = "DevCluster" # From the user's screenshot

# #   # --- Cluster Settings ---
# #   # Optional settings for the cluster.
# #   # Here, we enable container insights. You can add other settings if needed.
# #   setting {
# #     name  = "containerInsights"
# #     value = "enabled"
# #   }
# #   # service_connect_defaults {

# #   #   namespace = aws_service_discovery_http_namespace.namespace.arn
# #   # }
# #   # Configure Service Connect defaults using the *existing* namespace found by the data source
# #   service_connect_defaults {
# #     namespace = data.aws_service_discovery_http_namespace.namespace.arn # Reference data source ARN
# #   }

# #   # --- Capacity Providers (for Fargate) ---
# #   # Although Fargate is often the default, explicitly setting the capacity providers
# #   # ensures the desired configuration. The console screenshot implies Fargate is selected.
# #   # To explicitly configure Fargate as the default:
# #   configuration {
# #     execute_command_configuration {
# #       logging = "DEFAULT" # Or NONE, OVERRIDE
# #     }
# #   }

# #   # Default capacity provider strategy - ensures Fargate is used.
# #   # If you only want Fargate (no EC2), you usually don't need default_capacity_provider_strategy
# #   # but might need to set cluster capacity providers explicitly if mixing.
# #   # For a pure Fargate cluster as implied, often no specific capacity provider config is needed here,
# #   # as Fargate is managed by AWS. Tasks/Services will specify FARGATE/FARGATE_SPOT.
# #   # However, let's define them for clarity if needed.
# #   # Note: Often managed via `aws_ecs_cluster_capacity_providers` association instead.
# #   # For simplicity matching the console screenshot (Fargate selected):
# #   # We'll rely on specifying Fargate when defining ECS Services/Tasks later.
# #   # If you needed to *force* only Fargate capacity providers for the cluster upfront:
# #   # You might use:
# #   # capacity_providers = ["FARGATE", "FARGATE_SPOT"]

# #   tags = {
# #     Environment = var.Environment
# #   }


# # }

# # # --- Associate Fargate Capacity Providers with the Cluster ---
# # resource "aws_ecs_cluster_capacity_providers" "cluster_association" {
# #   cluster_name = aws_ecs_cluster.cluster_name.name

# #   # Explicitly associate the built-in Fargate capacity providers
# #   capacity_providers = ["FARGATE", "FARGATE_SPOT"]

# #   # --- Default Strategy ---
# #   # Define which providers are used by default if a service/task doesn't specify.
# #   # This strategy makes Fargate the primary default.
# #   default_capacity_provider_strategy {
# #     base              = 1  # At least one task will run on Fargate
# #     weight            = 10 # All tasks (above base) will try Fargate first
# #     capacity_provider = "FARGATE"
# #   }
# #   # You can optionally add FARGATE_SPOT to the default strategy with weight 0
# #   # if you want services to explicitly opt-in to Spot.
# #   default_capacity_provider_strategy {
# #     base              = 0
# #     weight            = 90 # Tasks won't use Spot unless specified in the service definition
# #     capacity_provider = "FARGATE_SPOT"
# #   }

# #   # --- IMPORTANT ---
# #   # Services and Tasks launched into this cluster can still specify their own
# #   # capacity provider strategy (e.g., only use FARGATE_SPOT, or a different weight).
# #   # This block just sets the cluster-wide default.
# # }

# # # --- Prerequisite: Cloud Map Namespace ---
# # # Ensure you have the following resource defined elsewhere in your configuration
# # # (from the previous document 'terraform_cloudmap_namespace'):

# # # resource "aws_service_discovery_public_dns_namespace" "namespace" {
# # #   name        = "development.local"
# # #   description = "Namespace for development"
# # #   tags = {
# # #     Environment = "development"
# # #     ManagedBy   = "Terraform"
# # #   }
# # # }
# # # --- ECS Service Definition ---
# # resource "aws_ecs_service" "my_app_service" {
# #   # Name for the ECS Service
# #   name = var.service_name



# #   # Reference the ECS cluster where this service will run
# #   # Ensure the cluster resource/data source is available in your configuration
# #   cluster = aws_ecs_cluster.cluster_name.id # Changed from var.cluster_name

# # # Reference the Task Definition created in Terraform
# #   task_definition = aws_ecs_task_definition.my_app_task.arn # <--- CORRECT REFERENCE

# #   # Set the desired number of tasks to keep running (from image)
# #   desired_count = 1

# #   # Specify the launch type (Fargate or EC2)
# #   # Since the cluster was configured for Fargate, we specify Fargate here.
# #   launch_type = "FARGATE"

# #   # --- Task Group (Placement Constraint) ---
# #   # The 'Task group' field in 'Run task' often relates to placement.
# #   # In a service, you can influence placement using constraints.
# #   # This example uses the task group name as a distinct instance constraint,
# #   # meaning tasks in this group prefer not to run on the same container instance (less relevant for Fargate).
# #   # A more common use is grouping for 'spread' placement across AZs.
# #   placement_constraints {
# #     type = "distinctInstance"
# #     # expression = "attribute:ecs.instance-group == ${var.task_group_name}" # Less common for Fargate
# #   }
# # }

# # resource "aws_iam_role" "ecs_task_execution_role" {
# #   name = "ecs-task-execution-role" # You can customize the name

# #   # Assume role policy allows ECS tasks to assume this role
# #   assume_role_policy = jsonencode({
# #     Version = "2012-10-17"
# #     Statement = [
# #       {
# #         Action = "sts:AssumeRole"
# #         Effect = "Allow"
# #         Principal = {
# #           Service = "ecs-tasks.amazonaws.com"
# #         }
# #       },
# #     ]
# #   })

# #   tags = {
# #     Name        = "ecs-task-execution-role"
# #     Environment = var.Environment # Assuming var.Environment is defined
# #   }
# # }

# # # Attach the standard AWS managed policy for ECS task execution
# # resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy_attachment" {
# #   role       = aws_iam_role.ecs_task_execution_role.name
# #   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# # }


# # # --- ECS Task Definition ---
# # # Defines the blueprint for your application task.

# # resource "aws_ecs_task_definition" "my_app_task" {
# #   # A unique name for your task definition family
# #   family = "my-app-task" # You can customize this

# #   # Specify Fargate requirements
# #   requires_compatibilities = ["FARGATE"]
# #   network_mode             = "awsvpc" # Required for Fargate

# #   # Define CPU and Memory limits (choose values compatible with Fargate)
# #   # See AWS docs for valid Fargate CPU/Memory combinations
# #   cpu    = "256"  # Example: 0.25 vCPU
# #   memory = "512" # Example: 512 MiB

# #   # Reference the IAM role created above for task execution
# #   execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

# #   # Optional: Define a task role if your application needs specific AWS permissions
# #   # task_role_arn = aws_iam_role.my_app_task_role.arn 

# #   # --- Container Definition ---
# #   # Defines the actual container(s) to run within the task.
# #   # This is a JSON string. Using jsonencode is recommended.
# #   container_definitions = jsonencode([
# #     {
# #       # Name for the container within the task definition
# #       name      = "my-app-container" # Customize as needed
# #       # Docker image to use (e.g., from Docker Hub or ECR)
# #       image     = "nginx:latest"     # Example: Using latest nginx image
# #       # CPU units allocated to this container (optional, often derived from task CPU)
# #       # cpu = 128 
# #       # Memory limits for the container (optional, often derived from task memory)
# #       # memory = 256 
# #       # memoryReservation = 128 # Soft limit
# #       essential = true # At least one container must be marked essential
# #       # Define port mappings if the container needs to expose ports
# #       portMappings = [
# #         {
# #           containerPort = 80  # Port the container listens on (nginx default)
# #           hostPort      = 80  # For awsvpc mode, hostPort is usually same as containerPort
# #           protocol      = "tcp"
# #           # Optional: Assign a name for Service Connect or Load Balancer reference
# #           # name = "my-app-http" 
# #         }
# #       ]
# #       # Optional: Configure logging (e.g., to CloudWatch Logs)
# #       logConfiguration = {
# #         logDriver = "awslogs"
# #         options = {
# #           # You need to create this log group or ensure it exists
# #           "awslogs-group"         = "/ecs/${var.service_name}" # Example log group name
# #           "awslogs-region"        = data.aws_region.current.name # Use current region
# #           "awslogs-stream-prefix" = "ecs" # Prefix for log streams
# #         }
# #       }
# #       # Optional: Add environment variables, secrets, health checks, etc.
# #       # environment = [
# #       #   { name = "MY_VARIABLE", value = "my_value" }
# #       # ]
# #     }
# #     # You can define more containers here if needed
# #   ])

# #   tags = {
# #     Name        = "my-app-task-definition"
# #     Environment = var.Environment # Assuming var.Environment is defined
# #   }
# # }

# # # --- Data Source for Current Region (for log configuration) ---
# # data "aws_region" "current" {}

# # # --- Optional: CloudWatch Log Group ---
# # # It's good practice to define the log group used by the task definition
# # resource "aws_cloudwatch_log_group" "ecs_log_group" {
# #   name = "/ecs/${var.service_name}" # Match the name used in logConfiguration

# #   tags = {
# #     Name        = "${var.service_name}-ecs-logs"
# #     Environment = var.Environment # Assuming var.Environment is defined
# #   }
# # }
