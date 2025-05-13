# --- ECS Service Auto Scaling Configuration ---
# --- ADDED THIS SECTION ---

# 1. Define the Scalable Target (registers the service with Application Auto Scaling)
resource "aws_appautoscaling_target" "ecs_service_scaling_target" {
  # Minimum number of tasks the service should run
  min_capacity = var.ecs_autoscale_min_tasks
  # Maximum number of tasks the service can scale out to
  max_capacity = var.ecs_autoscale_max_tasks

  # Resource ID format: service/<cluster_name>/<service_name>
  resource_id = "service/${aws_ecs_cluster.main_cluster.name}/${aws_ecs_service.main_app_service.name}"

  # Service namespace for ECS services
  service_namespace = "ecs"

  # The dimension to scale (number of tasks in an ECS service)
  scalable_dimension = "ecs:service:DesiredCount"

  # Optional: Role ARN if Application Auto Scaling needs specific permissions
  # Usually not required if your Terraform execution role has sufficient permissions
  # role_arn = "arn:aws:iam::ACCOUNT_ID:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"

  # Ensure the ECS service exists first
  depends_on = [aws_ecs_service.main_app_service]
}


# 2. Define the Scaling Policy (Target Tracking for ALB Request Count Per Target)
# This policy will adjust the task count to keep the average number of requests
# handled by each task at the target value.
resource "aws_appautoscaling_policy" "ecs_service_alb_requests_scaling_policy" {
  # --- MODIFIED BACK: Use service name variable in policy name ---
  name = "${var.ecs_service_name}-alb-requests-tracking"
  # --- END MODIFICATION ---

  # Link to the scalable target defined above
  resource_id        = aws_appautoscaling_target.ecs_service_scaling_target.resource_id
  service_namespace  = aws_appautoscaling_target.ecs_service_scaling_target.service_namespace
  scalable_dimension = aws_appautoscaling_target.ecs_service_scaling_target.scalable_dimension

  # Policy type: Target Tracking
  policy_type = "TargetTrackingScaling"

  # Configuration for Target Tracking policy
  target_tracking_scaling_policy_configuration {
    # Target value for the metric (average requests per task per minute)
    target_value = var.ecs_autoscale_requests_target_per_task # e.g., 1000

    # Predefined metric specification for ALB Request Count Per Target
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"

      # --- MODIFIED: Construct resource_label directly from ALB and TG ARNs ---
      # ResourceLabel identifies the ALB Target Group associated with the service
      # Format: <alb_arn_suffix>/targetgroup/<target_group_arn_suffix>
      # Assumes aws_lb.main_alb and aws_lb_target_group.my_app_tg are defined
      # in your alb.tf file (or another loaded .tf file).
      # We use regex to extract the part after 'loadbalancer/' and 'targetgroup/'.
      resource_label = "${regex("loadbalancer/(.*)", aws_lb.main_alb.arn)[0]}/targetgroup/${regex("targetgroup/(.*)", aws_lb_target_group.my_app_tg.arn)[0]}"
    }

    # Optional: Scale-in cooldown period (seconds) - prevents excessive scaling in
    scale_in_cooldown = 300

    # Optional: Scale-out cooldown period (seconds) - prevents excessive scaling out
    scale_out_cooldown = 60
  }

  # Ensure the scaling target exists first
  depends_on = [aws_appautoscaling_target.ecs_service_scaling_target]
}


# --- Optional: Scaling Policy (Target Tracking for CPU Utilization) ---
# --- Uncomment this block to enable CPU-based scaling INSTEAD of or IN ADDITION TO request scaling ---
# resource "aws_appautoscaling_policy" "ecs_service_cpu_scaling_policy" {
#   name = "${var.ecs_service_name}-cpu-tracking" # Using variable reference
#   resource_id        = aws_appautoscaling_target.ecs_service_scaling_target.resource_id
#   service_namespace  = aws_appautoscaling_target.ecs_service_scaling_target.service_namespace
#   scalable_dimension = aws_appautoscaling_target.ecs_service_scaling_target.scalable_dimension
#   policy_type        = "TargetTrackingScaling"
#
#   target_tracking_scaling_policy_configuration {
#     target_value = var.ecs_autoscale_cpu_target_percent # e.g., 75
#     predefined_metric_specification {
#       predefined_metric_type = "ECSServiceAverageCPUUtilization"
#     }
#     # scale_in_cooldown  = 300
#     # scale_out_cooldown = 60
#   }
#   depends_on = [aws_appautoscaling_target.ecs_service_scaling_target]
# }


# --- Optional: Scaling Policy (Target Tracking for Memory Utilization) ---
# --- Uncomment this block to enable Memory-based scaling INSTEAD of or IN ADDITION TO other policies ---
# resource "aws_appautoscaling_policy" "ecs_service_memory_scaling_policy" {
#   name = "${var.ecs_service_name}-memory-tracking" # Using variable reference
#   resource_id        = aws_appautoscaling_target.ecs_service_scaling_target.resource_id
#   service_namespace  = aws_appautoscaling_target.ecs_service_scaling_target.service_namespace
#   scalable_dimension = aws_appautoscaling_target.ecs_service_scaling_target.scalable_dimension
#   policy_type        = "TargetTrackingScaling"
#
#   target_tracking_scaling_policy_configuration {
#     target_value = var.ecs_autoscale_memory_target_percent # e.g., 75
#     predefined_metric_specification {
#       predefined_metric_type = "ECSServiceAverageMemoryUtilization"
#     }
#     # scale_in_cooldown  = 300
#     # scale_out_cooldown = 60
#   }
#   depends_on = [aws_appautoscaling_target.ecs_service_scaling_target]
# }

