# --- Aws Provider Vars ---
variable "aws_region" {
  description = "value of region"
  type        = string
  default     = "eu-north-1"
}

# --- Namespace var ---
variable "namespace_name" {
  type    = string
  default = "development"
}

# --- VPC Vars ---
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "vpc_name_tag" {
  description = "Name tag for the VPC"
  type        = string
  default     = "ecs-development-vpc"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "development"
}

# --- Subnets Vars ---
variable "availability_zones" {
  description = "List of Availability Zones to use for subnets"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}

# --- Public Subnets Vars ---
variable "public_subnet_cidr_blocks" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "map_public_ip_on_launch" {
  description = "Assign public IP to instances launched in the public subnet"
  type        = bool
  default     = true
}

variable "public_subnet_names" {
  description = "Names for public subnets"
  type        = list(string)
  default     = ["public-subnet-az1", "public-subnet-az2"]
}

# --- Private Subnets Vars ---
variable "private_subnet_cidr_blocks" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "private_subnet_names" {
  description = "Names for private subnets"
  type        = list(string)
  default     = ["private-subnet-az1", "private-subnet-az2"]
}

# --- Internet Gateway Vars ---
variable "internet_gateway_name" {
  description = "Name tag for the Internet Gateway"
  type        = string
  default     = "ecs-development-igw"
}

# --- Elastic IP and NAT Gateway Vars ---
variable "nat_eip_name" {
  description = "Name tag for the NAT Elastic IP"
  type        = string
  default     = "ecs-development-nat-eip"
}

variable "nat_gateway_name" {
  description = "Name tag for the NAT Gateway"
  type        = string
  default     = "ecs-development-nat-gw"
}


# --- Route Tables ---
# --- Public Route Table Vars ---
variable "public_route_cidr_block" {
  description = "CIDR block for public route table"
  type        = string
  default     = "0.0.0.0/0"
}

variable "public_route_table_name" {
  description = "Name tag for public route table"
  type        = string
  default     = "public-route-table"
}

# --- Private Route Table Vars ---
variable "private_route_cidr_block" {
  description = "CIDR block for private route table"
  type        = string
  default     = "0.0.0.0/0"
}

variable "private_route_table_name" {
  description = "Name tag for private route table"
  type        = string
  default     = "private-route-table"
}

# --- Security Groups Vars ---
variable "service_name" {
  description = "The name of the service or application"
  type        = string
  default     = "ecs-development-svc"
}

variable "alb_sg_description" {
  description = "Description for the ALB security group"
  type        = string
  default     = "Security group for the Application Load Balancer"
}

variable "alb_http_port" {
  description = "HTTP port for the ALB"
  type        = number
  default     = 80
}

variable "alb_https_port" {
  description = "HTTPS port for the ALB"
  type        = number
  default     = 443
}

variable "allowed_http_cidrs" {
  description = "CIDR blocks allowed to access HTTP on the ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_https_cidrs" {
  description = "CIDR blocks allowed to access HTTPS on the ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_egress_cidrs" {
  description = "CIDR blocks allowed for outbound traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# --- Security Group for ECS Tasks Vars ---
variable "ecs_task_sg_description" {
  description = "Description for ECS Task security group"
  type        = string
  default     = "Security group for ECS Fargate tasks"
}

variable "ecs_task_ingress_description" {
  description = "Ingress rule description for ECS Task SG"
  type        = string
  default     = "Allow traffic from ALB"
}

variable "ecs_container_port" {
  description = "Port on which the ECS container listens (e.g., nginx default: 80)"
  type        = number
  default     = 80
}

# --- Application Load Balancer (ALB) Vars ---
variable "alb_internal" {
  description = "Whether the ALB is internal (true) or internet-facing (false)"
  type        = bool
  default     = false
}

variable "alb_subnets" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
  default     = ["public-subnet-az1", "public-subnet-az2"]
}

variable "enable_alb_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}

# --- ALB Target Group Vars ---
variable "tg_port" {
  description = "Port that the Target Group listens on (should match container port)"
  type        = number
  default     = 80
}

variable "tg_protocol" {
  description = "Protocol used by the Target Group"
  type        = string
  default     = "HTTP"
}

variable "tg_target_type" {
  description = "Target type for the ALB target group (instance, ip, lambda)"
  type        = string
  default     = "ip"
}

# --- Health Check Configurations ---
variable "tg_health_check_enabled" {
  description = "Whether health checks are enabled"
  type        = bool
  default     = true
}

variable "tg_health_check_interval" {
  description = "Time between health checks in seconds"
  type        = number
  default     = 30
}

variable "tg_health_check_path" {
  description = "Path for the health check"
  type        = string
  default     = "/"
}

variable "tg_health_check_port" {
  description = "Port used for health check (can be numeric or 'traffic-port')"
  type        = string
  default     = "traffic-port"
}

variable "tg_health_check_protocol" {
  description = "Protocol used for health check"
  type        = string
  default     = "HTTP"
}

variable "tg_health_check_timeout" {
  description = "Timeout in seconds for each health check attempt"
  type        = number
  default     = 5
}

variable "tg_health_check_healthy_threshold" {
  description = "Number of consecutive successful checks before target is considered healthy"
  type        = number
  default     = 3
}

variable "tg_health_check_unhealthy_threshold" {
  description = "Number of consecutive failed checks before target is considered unhealthy"
  type        = number
  default     = 3
}

variable "tg_health_check_matcher" {
  description = "Expected HTTP response code for a healthy target"
  type        = string
  default     = "200"
}

# --- ALB Listener ---
variable "listener_port" {
  description = "Port that the ALB listener uses"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "Protocol for the ALB listener (HTTP or HTTPS)"
  type        = string
  default     = "HTTP"
}

variable "listener_default_action_type" {
  description = "Default action type for the ALB listener (e.g., forward)"
  type        = string
  default     = "forward"
}

# --- ECS Cluster VArs ---
variable "ecs_cluster_name" {
  description = "Name of the ECS Cluster"
  type        = string
  default     = "ecs-development-cluster"
}

variable "enable_container_insights" {
  description = "enbale or disable container isnsight"
  type        = string
  default     = "enabled"
}

variable "ecs_execute_command_logging" {
  description = "Logging option for ECS Exec (DEFAULT | OVERRIDE | NONE)"
  type        = string
  default     = "OVERRIDE"
}

# --- ECS Task Execution IAM Role ---
variable "ecs_task_execution_role_name" {
  description = "The name of the ECS Task Execution Role."
  type        = string
  default     = "ecs-task-execution-role"
}

variable "ecs_task_execution_policy_arn" {
  description = "The ARN of the ECS Task Execution Policy."
  type        = string
  default     = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# --- ECS Cluster Capacity provider Definition ---
variable "capacity_providers" {
  description = "List of capacity providers to associate with the ECS cluster."
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "default_capacity_provider_strategy" {
  description = "The strategy configuration for the ECS capacity providers."
  type = list(object({
    base              = number
    weight            = number
    capacity_provider = string
  }))
  default = [
    {
      base              = 1
      weight            = 20
      capacity_provider = "FARGATE"
    },
    {
      base              = 0
      weight            = 80
      capacity_provider = "FARGATE_SPOT"
    }
  ]
}

# --- ECS Task Definition ---
variable "task_definition_family" {
  description = "Unique name for the task definition family."
  type        = string
  default     = "ecs-development-task-definition-family"
}

variable "requires_compatibility" {
  description = "Specify Fargate compatibility is required"
  type        = string
  default     = "FARGATE"
}

variable "networkmode" {
  description = "define network mode"
  type        = string
  default     = "awsvpc"
}

variable "task_os_family" {
  description = "Operating system family for the ECS task runtime platform (e.g., LINUX, WINDOWS_SERVER_2019_FULL)."
  type        = string
  default     = "LINUX"
}

variable "task_cpu_architecture" {
  description = "CPU architecture for the ECS task runtime platform (e.g., X86_64, ARM64)."
  type        = string
  default     = "X86_64"
}

variable "task_cpu" {
  description = "CPU units for the task (e.g., 1024 = 1 vCPU)."
  type        = number
  default     = 1024
}

variable "task_memory" {
  description = "Memory in MiB for the task (e.g., 3072 = 3 GB)."
  type        = number
  default     = 2048
}

# --- Container Definition VArs ---
variable "container_name" {
  description = "Name of the container within the task definition."
  type        = string
  default     = "my-app-container"
}

variable "container_image" {
  description = "Docker image URL for the container (e.g., account-id.dkr.ecr.region.amazonaws.com/my-repo:latest)."
  type        = string
  default     = "nginx:latest"
}

variable "container_cpu" {
  type    = number
  default = 512
}

variable "container_allocate_memory" {
  type    = number
  default = 512
}

variable "container_reserved_memory" {
  type    = number
  default = 256
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number
  default     = 80
}

# --- CloudWatch Log configuration  VArs--- 

variable "log_group_name" {
  description = "Name of the CloudWatch Log Group for container logs."
  type        = string
  default     = "/ecs/my-app" # Example log group name
}

variable "log_stream_prefix" {
  description = "Prefix for log streams within the CloudWatch Log Group."
  type        = string
  default     = "ecs" # Example prefix
}

variable "ecs_execute_command_log_group_name" {
  description = "The name of the CloudWatch Log Group for ECS Execute Command logs."
  type        = string
  default     = "/aws/ecs/execute-command/custom-logs" # Or derive from cluster name, etc.
}

# --- Common Tags ---
# Ensure this is defined if you haven't already
variable "common_tags" {
  description = "A map of common tags to apply to all resources."
  type        = map(string)
  default = {
    Environment = "development"
  }
}


# --- ECS Service Variables ---
variable "ecs_service_name" {
  description = "Name for the ECS service."
  type        = string
  default     = "ecs-development-service"
}

variable "ecs_service_desired_count" {
  description = "Number of task instances to run for the service."
  type        = number
  default     = 1
}

variable "ecs_service_launch_type" {
  description = "define launch type"
  type        = string
  default     = "FARGATE"
}

variable "ecs_service_assign_public_ip" {
  description = "Whether to assign public IPs to tasks (typically false for private subnets)."
  type        = bool
  default     = false
}


