# Terraform AWS EC2 Instance Deployment

This Terraform configuration deploys a single Amazon EC2 instance along with a basic security group configured for web access (HTTP) and SSH.

## Overview

The configuration performs the following actions:

1.  **Defines the AWS Provider:** Configures the AWS provider for the specified region.
2.  **Creates a Security Group:** Sets up a security group (`aws_security_group.web_server_sg`) that allows:
    * Inbound TCP traffic on port 80 (HTTP) from anywhere (`0.0.0.0/0`).
    * Inbound TCP traffic on port 22 (SSH) from anywhere (`0.0.0.0/0`). **Note:** For production environments, it's highly recommended to restrict the SSH CIDR block to your specific IP address.
    * All outbound traffic.
3.  **Creates an EC2 Instance:** Launches an EC2 instance (`aws_instance.my_ec2`) using the specified AMI, instance type, and key pair. It attaches the security group created above and configures the root EBS volume.

## Prerequisites

* **Terraform:** Ensure Terraform (version compatible with the configuration, likely >= 1.0) is installed on your local machine.
* **AWS Credentials:** Configure your AWS credentials appropriately. This can be done via environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`), shared credential files (`~/.aws/credentials`), or an IAM role if running Terraform from an EC2 instance or ECS task.
* **EC2 Key Pair:** An existing EC2 Key Pair must be available in the target AWS region, and its name should be provided via the `key_name` variable.

## Files

* `aws-ec2.tf`: Contains the main configuration for the EC2 instance and security group.
* `vars.tf` (Assumed): Should contain the variable definitions (see below).
* `outputs.tf`: Defines the outputs generated after applying the configuration.
* `provider.tf` (Optional): Can be used to define the provider configuration separately.

## Variables

The following variables need to be defined (e.g., in a `terraform.tfvars` file or via command-line arguments):

| Variable        | Description                                           | Type   | Example Value        |
| :-------------- | :---------------------------------------------------- | :----- | :------------------- |
| `region`        | The AWS region where resources will be created.       | `string` | `"us-east-1"`        |
| `ami`           | The ID of the Amazon Machine Image (AMI) to use.      | `string` | `"ami-0abcdef123456"` |
| `instance_type` | The type of EC2 instance to launch (e.g., t2.micro). | `string` | `"t3.micro"`         |
| `key_name`      | The name of the EC2 Key Pair for SSH access.          | `string` | `"my-aws-keypair"`   |
| `vpc_id`        | (Optional) The ID of the VPC to launch into if not using the default VPC. | `string` | `"vpc-0123456789"`   |

*(Note: The `vpc_id` variable might be needed in `aws_security_group.web_server_sg` if not using the default VPC).*

## Usage

1.  **Initialize:** Navigate to the directory containing the Terraform files and run:
    ```bash
    terraform init
    ```
2.  **Plan:** Review the changes Terraform will make:
    ```bash
    terraform plan -var-file=your_vars.tfvars # (Optional: use a .tfvars file)
    ```
    *Or pass variables directly:*
    ```bash
    terraform plan -var="region=us-east-1" -var="ami=ami-..." -var="instance_type=t3.micro" -var="key_name=my-key"
    ```
3.  **Apply:** Create the resources:
    ```bash
    terraform apply -var-file=your_vars.tfvars # (Optional: use a .tfvars file)
    ```
    *Or pass variables directly:*
    ```bash
    terraform apply -var="region=us-east-1" -var="ami=ami-..." -var="instance_type=t3.micro" -var="key_name=my-key"
    ```
    Confirm the action by typing `yes`.

## Outputs

After successful application, Terraform will output the following values (defined in `outputs.tf`):

* `instance_id`: The ID of the created EC2 instance.
* `instance_arn`: The ARN of the created EC2 instance.
* `instance_public_ip`: The public IP address of the instance (if applicable).
* `instance_private_ip`: The private IP address of the instance.
* `instance_public_dns`: The public DNS name of the instance (if applicable).
* `instance_private_dns`: The private DNS name of the instance.
* `web_server_security_group_id`: The ID of the created security group.
* `web_server_security_group_arn`:
