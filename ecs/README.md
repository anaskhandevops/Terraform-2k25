# Terraform AWS ECS Infrastructure

This repository contains Terraform configuration files to provision an AWS Elastic Container Service (ECS) environment, including networking (VPC), load balancing (ALB), security groups, and the ECS cluster itself.

## Description

This Terraform project sets up the necessary AWS infrastructure to run containerized applications on ECS Fargate (or EC2, depending on configuration). It includes:

* **Networking:** VPC, Subnets (Public/Private), Route Tables, Internet Gateway, NAT Gateway (if applicable).
* **Security:** Security Groups for ALB, ECS Services, and potentially Bastion hosts or databases.
* **Load Balancing:** Application Load Balancer (ALB), Target Groups, and Listeners.
* **ECS:** ECS Cluster, Task Definitions, ECS Services, IAM Roles (Task Execution Role, Task Role), CloudWatch Log Groups, and Capacity Providers/Strategies.

## Prerequisites

* [Terraform](https://developer.hashicorp.com/terraform/downloads) (version specified in `provider.tf` or inferred)
* [AWS Account](https://aws.amazon.com/)
* [AWS Credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) configured for Terraform (e.g., via environment variables, shared credentials file, or IAM instance profile).
* An existing AWS Cloud Map Private DNS Namespace (if using Service Connect and referencing an existing one).

## File Structure

.├── .terraform/             # Terraform working directory (managed by Terraform)├── .terraform.lock.hcl     # Terraform dependency lock file├── alb.tf                  # Defines Application Load Balancer, Target Groups, Listeners├── ecs.tf                  # Defines ECS Cluster, Task Definitions, Services, IAM Roles├── main.tf                 # Main orchestration file (if applicable) or core resources├── outputs.tf              # Defines outputs (e.g., ALB DNS name, Cluster name)├── provider.tf             # Defines AWS provider and required version├── securitygroup.tf        # Defines Security Group rules├── terraform.tfstate       # Terraform state file (DO NOT COMMIT)├── terraform.tfstate.backup# Terraform state backup file (DO NOT COMMIT)├── variables.tf            # Defines input variables├── vpc.tf                  # Defines VPC, Subnets, Route Tables, Gateways└── README.md               # This file
## Usage

1.  **Clone the repository:**
    ```bash
    git clone <your-repository-url>
    cd <repository-directory>
    ```

2.  **Configure Variables:**
    Create a `terraform.tfvars` file (or use `-var` flags) to provide values for the required variables defined in `variables.tf`. See the Inputs section below.
    ```terraform
    # Example terraform.tfvars
    aws_region     = "us-east-1"
    environment    = "development"
    vpc_id         = "vpc-xxxxxxxxxxxxxxxxx" # If using existing VPC/Namespace
    namespace_name = "development"         # If using existing Namespace
    # ... other required variables
    ```

3.  **Initialize Terraform:**
    ```bash
    terraform init
    ```

4.  **Plan the deployment:**
    ```bash
    terraform plan -var-file=terraform.tfvars
    ```
    Review the plan to ensure it matches your expectations.

5.  **Apply the configuration:**
    ```bash
    terraform apply -var-file=terraform.tfvars
    ```
    Type `yes` when prompted to confirm.

6.  **Destroy the infrastructure (if needed):**
    ```bash
    terraform destroy -var-file=terraform.tfvars
    ```

## Inputs (Variables)

Review `variables.tf` for a complete list of input variables. Key variables likely include:

| Variable Name                        | Description                                                                 | Type         | Default Value | Required |
| :----------------------------------- | :-------------------------------------------------------------------------- | :----------- | :------------ | :------- |
| `aws_region`                         | The AWS region to deploy resources into.                                    | `string`     | `null`        | Yes      |
| `environment`                        | The deployment environment (e.g., development, staging, production).        | `string`     | `null`        | Yes      |
| `vpc_id`                             | ID of the VPC (required if using existing VPC/Namespace for Service Connect). | `string`     | `null`        | Maybe    |
| `namespace_name`                     | Name of the Cloud Map Namespace (if using existing for Service Connect).    | `string`     | `development` | Maybe    |
| `ecs_cluster_name`                   | Name for the ECS Cluster.                                                   | `string`     | `my-cluster`  | No       |
| `task_definition_family`             | Family name for the ECS Task Definition.                                    | `string`     | `my-app`      | No       |
| `container_image`                    | Docker image for the application container.                                 | `string`     | `null`        | Yes      |
| `container_port`                     | Port the application container listens on.                                  | `number`     | `8080`        | No       |
| `ecs_execute_command_logging`        | Logging configuration for ECS Execute Command (NONE, DEFAULT, OVERRIDE).    | `string`     | `OVERRIDE`    | No       |
| `ecs_execute_command_log_group_name` | CloudWatch Log Group name if `ecs_execute_command_logging` is OVERRIDE.     | `string`     | `/aws/ecs/...`| Maybe    |
| `enable_container_insights`          | Enable/disable Container Insights for the cluster.                          | `string`     | `"enabled"`   | No       |
| `capacity_providers`                 | List of capacity providers to associate with the cluster (e.g., ["FARGATE"]). | `list(string)` | `["FARGATE"]` | No       |
| `default_capacity_provider_strategy` | Default strategy for placing tasks on capacity providers.                   | `list(object)` | (See vars.tf) | No       |
| `common_tags`                        | Common tags to apply to all resources.                                      | `map(string)`| `{}`          | No       |
| `log_group_name`                     | Name of the CloudWatch Log Group for container logs.                        | `string`     | `null`        | Yes      |
| `log_stream_prefix`                  | Prefix for container log streams.                                           | `string`     | `ecs`         | No       |
| *(Add other important variables)* | *(Describe other variables from variables.tf)* | ...          | ...           | ...      |

## Outputs

Review `outputs.tf` for a complete list of outputs. Key outputs may include:

| Output Name          | Description                                      |
| :------------------- | :----------------------------------------------- |
| `alb_dns_name`       | The DNS name of the Application Load Balancer.   |
| `ecs_cluster_name`   | The name of the created ECS Cluster.             |
| `ecs_service_name`   | The name of the created ECS Service.             |
| `task_definition_arn`| The ARN of the created ECS Task Definition.      |
| `task_exec_role_arn` | ARN of the ECS Task Execution IAM Role.          |
| `task_role_arn`      | ARN of the ECS Task IAM Role.                    |
| *(Add others)* | *(Describe other outputs from outputs.tf)* |

## Notes

* Ensure your `.gitignore` file includes `terraform.tfstate`, `terraform.tfstate.backup`, `.terraform/`, and any `.tfvars` files containing sensitive information. Example `.gitignore`:
    ```
    # Terraform state files
    terraform.tfstate
    terraform.tfstate.backup

    # Terraform working directory
    .terraform/

    # Terraform plan files
    *.tfplan

    # Terraform variable files (if they contain secrets)
    *.tfvars
    *.tfvars.json

    # Override file
    override.tf
    override.tf.json
    *_override.tf
    *_override.tf.json

    # Crash log files
    crash.log
    crash.*.log

    # Exclude all .tfstate files in subdirectories
    **/.tfstate
    **/.tfstate.d

    # Debug output files
    terraform.log

    # Provider binary files
    .terraform.d/plugins/
    ```
* Customize IAM policies (`ecs.tf`) attached to the `ecs_task_role` to grant your application the specific AWS permissions it needs (least privilege principle).
* Review security group rules (`securitygroup.tf`) to ensure they are appropriately restricted.
