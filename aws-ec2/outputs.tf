# --- EC2 Instance Outputs ---

output "instance_id" {
  description = "The ID of the created EC2 instance."
  value       = aws_instance.my_ec2.id
}

output "instance_arn" {
  description = "The ARN of the created EC2 instance."
  value       = aws_instance.my_ec2.arn
}

output "instance_public_ip" {
  description = "The public IP address assigned to the EC2 instance (if applicable)."
  # Note: This will be empty if the instance is in a private subnet without a public IP.
  value       = aws_instance.my_ec2.public_ip
}

output "instance_private_ip" {
  description = "The private IP address assigned to the EC2 instance."
  value       = aws_instance.my_ec2.private_ip
}

output "instance_public_dns" {
  description = "The public DNS name assigned to the EC2 instance (if applicable)."
  # Note: This will be empty if the instance doesn't have a public IP/DNS.
  value       = aws_instance.my_ec2.public_dns
}

output "instance_private_dns" {
  description = "The private DNS name assigned to the EC2 instance."
  value       = aws_instance.my_ec2.private_dns
}

# --- Security Group Outputs ---

output "web_server_security_group_id" {
  description = "The ID of the security group created for the web server."
  value       = aws_security_group.web_server_sg.id
}

output "web_server_security_group_arn" {
  description = "The ARN of the security group created for the web server."
  value       = aws_security_group.web_server_sg.arn
}


# --- Auto Scaling Target Output ---

output "ecs_autoscaling_target_resource_id" {
  description = "The resource ID of the registered scalable target."
  value       = aws_appautoscaling_target.ecs_service_scaling_target.resource_id
}

# --- Auto Scaling Policy Outputs ---

output "ecs_alb_requests_scaling_policy_arn" {
  description = "The ARN of the ALB Request Count scaling policy."
  value       = aws_appautoscaling_policy.ecs_service_alb_requests_scaling_policy.arn
}

output "ecs_alb_requests_scaling_policy_name" {
  description = "The name of the ALB Request Count scaling policy."
  value       = aws_appautoscaling_policy.ecs_service_alb_requests_scaling_policy.name
}

# --- Optional: Outputs for other policies (Uncomment if policies are enabled) ---
# output "ecs_cpu_scaling_policy_arn" {
#   description = "The ARN of the CPU scaling policy."
#   value       = aws_appautoscaling_policy.ecs_service_cpu_scaling_policy.arn
# }
#
# output "ecs_memory_scaling_policy_arn" {
#   description = "The ARN of the Memory scaling policy."
#   value       = aws_appautoscaling_policy.ecs_service_memory_scaling_policy.arn
# }
