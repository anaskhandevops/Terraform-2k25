# --- Aws Provider Defination ---
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}



# --- Data Sources Defination---
data "aws_region" "current" {}

data "aws_service_discovery_http_namespace" "namespace" {
  name = var.namespace_name
}
