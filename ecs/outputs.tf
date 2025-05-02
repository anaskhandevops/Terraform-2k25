# --- ECS Cluster Outputs ---

output "ecs_cluster_name" {
  description = "The name of the created ECS cluster."
  value       = aws_ecs_cluster.main_cluster.name
}

output "ecs_cluster_arn" {
  description = "The ARN of the created ECS cluster."
  value       = aws_ecs_cluster.main_cluster.arn
}

# --- ECS Service Outputs ---

output "ecs_service_name" {
  description = "The name of the created ECS service."
  value       = aws_ecs_service.main_app_service.name
}

output "ecs_service_arn" {
  description = "The ARN of the created ECS service."
  value       = aws_ecs_service.main_app_service.id # Service ARN is accessed via 'id' attribute
}

# --- ECS Task Definition Output ---

output "ecs_task_definition_arn" {
  description = "The ARN of the created ECS task definition."
  value       = aws_ecs_task_definition.app_task_def.arn
}

# --- IAM Role Outputs ---

output "ecs_task_role_arn" {
  description = "The ARN of the IAM role used by the ECS tasks."
  value       = aws_iam_role.ecs_task_role.arn
}

output "ecs_task_execution_role_arn" {
  description = "The ARN of the IAM role used by the ECS agent (task execution)."
  value       = aws_iam_role.ecs_task_execution_role.arn
}

# --- CloudWatch Log Group Outputs ---

output "ecs_container_log_group_name" {
  description = "The name of the CloudWatch Log Group for container logs."
  value       = aws_cloudwatch_log_group.container_logs.name
}

output "ecs_execute_command_log_group_name" {
  description = "The name of the CloudWatch Log Group for execute command logs."
  value       = aws_cloudwatch_log_group.execute_command_logs.name
}

# --- Optional: Output for the one-off task (if uncommented) ---
# output "ecs_one_off_task_arns" {
#   description = "The ARNs of the one-off tasks launched by Terraform (if aws_ecs_task is used)."
#   # Note: aws_ecs_task resource doesn't directly output the running task ARN easily.
#   # This output might be less useful unless you specifically need to track the resource itself.
#   # value = aws_ecs_task.my_batch_job[*].id # Example if using count > 1
#   value = "See AWS Console or use AWS CLI for running task ARNs launched by aws_ecs_task resource."
# }

# --- Application Load Balancer (ALB) Outputs ---

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer."
  value       = aws_lb.main_alb.dns_name
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer."
  value       = aws_lb.main_alb.arn
}

output "alb_zone_id" {
  description = "The canonical hosted zone ID of the Application Load Balancer (useful for Route 53 Alias records)."
  value       = aws_lb.main_alb.zone_id
}

# --- ALB Target Group Outputs ---

output "alb_target_group_arn" {
  description = "The ARN of the ALB Target Group."
  value       = aws_lb_target_group.my_app_tg.arn
}

output "alb_target_group_name" {
  description = "The Name of the ALB Target Group."
  value       = aws_lb_target_group.my_app_tg.name
}

# --- ALB Listener Outputs ---

output "alb_http_listener_arn" {
  description = "The ARN of the HTTP listener."
  value       = aws_lb_listener.http_listener.arn
}

# --- Optional: HTTPS Listener Output (Uncomment if https_listener is used) ---
# output "alb_https_listener_arn" {
#   description = "The ARN of the HTTPS listener."
#   value       = aws_lb_listener.https_listener.arn
# }

# --- AWS Provider/Region Output ---

output "aws_current_region_name" {
  description = "The name of the AWS region being used by the provider."
  value       = data.aws_region.current.name
}

# --- Service Discovery Namespace Outputs ---

output "service_discovery_namespace_id" {
  description = "The ID of the retrieved HTTP Service Discovery namespace."
  value       = data.aws_service_discovery_http_namespace.namespace.id
}

output "service_discovery_namespace_arn" {
  description = "The ARN of the retrieved HTTP Service Discovery namespace."
  value       = data.aws_service_discovery_http_namespace.namespace.arn
}

output "service_discovery_namespace_name" {
  description = "The Name of the retrieved HTTP Service Discovery namespace."
  value       = data.aws_service_discovery_http_namespace.namespace.name
}

output "service_discovery_namespace_description" {
  description = "The description of the retrieved HTTP Service Discovery namespace."
  value       = data.aws_service_discovery_http_namespace.namespace.description
}

# --- ALB Security Group Outputs ---

output "alb_security_group_id" {
  description = "The ID of the security group created for the Application Load Balancer."
  value       = aws_security_group.alb_sg.id
}

output "alb_security_group_arn" {
  description = "The ARN of the security group created for the Application Load Balancer."
  value       = aws_security_group.alb_sg.arn
}

# --- ECS Task Security Group Outputs ---

output "ecs_task_security_group_id" {
  description = "The ID of the security group created for the ECS tasks."
  value       = aws_security_group.ecs_task_sg.id
}

output "ecs_task_security_group_arn" {
  description = "The ARN of the security group created for the ECS tasks."
  value       = aws_security_group.ecs_task_sg.arn
}

# --- VPC Outputs ---

output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.ecs_dev_vpc.id
}

output "vpc_arn" {
  description = "The ARN of the created VPC."
  value       = aws_vpc.ecs_dev_vpc.arn
}

output "vpc_cidr_block" {
  description = "The primary CIDR block of the created VPC."
  value       = aws_vpc.ecs_dev_vpc.cidr_block
}

# --- Public Subnet Outputs ---

output "public_subnet_ids" {
  description = "A list of the IDs of the created public subnets."
  value = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]
}

output "public_subnet_arns" {
  description = "A list of the ARNs of the created public subnets."
  value = [
    aws_subnet.public_subnet_1.arn,
    aws_subnet.public_subnet_2.arn
  ]
}

output "public_subnet_availability_zones" {
  description = "A list of the Availability Zones for the public subnets."
  value = [
    aws_subnet.public_subnet_1.availability_zone,
    aws_subnet.public_subnet_2.availability_zone
  ]
}

# --- Private Subnet Outputs ---

output "private_subnet_ids" {
  description = "A list of the IDs of the created private subnets."
  value = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]
}

output "private_subnet_arns" {
  description = "A list of the ARNs of the created private subnets."
  value = [
    aws_subnet.private_subnet_1.arn,
    aws_subnet.private_subnet_2.arn
  ]
}

output "private_subnet_availability_zones" {
  description = "A list of the Availability Zones for the private subnets."
  value = [
    aws_subnet.private_subnet_1.availability_zone,
    aws_subnet.private_subnet_2.availability_zone
  ]
}

# --- Internet Gateway Output ---

output "internet_gateway_id" {
  description = "The ID of the created Internet Gateway."
  value       = aws_internet_gateway.gw.id
}

# --- NAT Gateway Outputs ---

output "nat_gateway_id" {
  description = "The ID of the created NAT Gateway."
  value       = aws_nat_gateway.nat_gw.id
}

output "nat_gateway_public_ip" {
  description = "The public IP address allocated to the NAT Gateway (via EIP)."
  value       = aws_eip.nat_eip.public_ip
}

# --- Route Table Outputs ---

output "public_route_table_id" {
  description = "The ID of the public route table."
  value       = aws_route_table.public_rt.id
}

output "private_route_table_id" {
  description = "The ID of the private route table."
  value       = aws_route_table.private_rt.id
}
