output "namespace_id" {
  description = "The ID of the created Cloud Map HTTP namespace."
  value       = aws_service_discovery_http_namespace.namespace.id
}

output "namespace_arn" {
  description = "The ARN of the created Cloud Map HTTP namespace."
  value       = aws_service_discovery_http_namespace.namespace.arn
}

# output "namespace_hosted_zone" {
#   description = "The ID of the Route 53 hosted zone that was created automatically for the namespace."
#   value       = aws_service_discovery_public_dns_namespace.namespace.hosted_zone
# }
