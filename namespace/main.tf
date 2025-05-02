
  # --- Instance Discovery Method ---
  # By using the resource type "aws_service_discovery_http_namespace",
  # we are explicitly selecting the "API calls" method for instance discovery.
  # Other resource types (aws_service_discovery_private_dns_namespace or
  # aws_service_discovery_public_dns_namespace) would be used for DNS-based discovery.

resource "aws_service_discovery_http_namespace" "namespace" {

  name = var.namespace_name

  description = "Namespace for development"

  tags = {
    Environment = var.tag_name
  }
}



