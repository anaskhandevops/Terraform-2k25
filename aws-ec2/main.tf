terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "my_ec2" {
  ami           = var.ami
  instance_type = var.instance_type 
  key_name      = var.key_name       
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  tags = {
    Name        = "my-web-server-01"  

  }
    # --- Configure Root Volume Storage (Based on user image) ---
  root_block_device {
    # Device name usually defaults correctly based on AMI, but can be specified if needed.
    # device_name = "/dev/sda1" 
    
    volume_size           = 8     
    volume_type           = "gp3" 
    iops                  = 3000  
    throughput            = 125   
    delete_on_termination = true  
    encrypted             = false 
    # kms_key_id          = null # Only applicable if encrypted = true
  }
  
}

# --- Security Group Definition ---

resource "aws_security_group" "web_server_sg" {
  name        = "web-server-sg"
  description = "Allow HTTP and SSH inbound traffic"

  # If you are not using the default VPC, you need to specify the VPC ID
  # vpc_id      = aws_vpc.my_vpc.id # Example: uncomment and replace if needed

  # Ingress rule for SSH (Port 22)
  ingress {
    description      = "SSH access"
    from_port        = 22                   # Starting port number
    to_port          = 22                   # Ending port number (same for a single port)
    protocol         = "tcp"                # Protocol type (TCP for SSH)
    cidr_blocks      = ["0.0.0.0/0"]        # Allowed source IP range (0.0.0.0/0 means anywhere - consider restricting this for better security)
    # For better security, replace "0.0.0.0/0" with your specific IP address like ["YOUR_IP/32"]
    # e.g., cidr_blocks = ["203.0.113.5/32"]
  }

  # Ingress rule for HTTP (Port 80)
  ingress {
    description      = "HTTP access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"                # Protocol type (TCP for HTTP)
    cidr_blocks      = ["0.0.0.0/0"]        # Allow traffic from anywhere
  }

  # Egress rule (Outbound traffic) - Allows all outbound traffic by default
  egress {
    from_port        = 0                    # Allow traffic to any port
    to_port          = 0                    # Allow traffic to any port
    protocol         = "-1"                 # Allow any protocol (-1 signifies all protocols)
    cidr_blocks      = ["0.0.0.0/0"]        # Allow traffic to any destination
  }


  tags = {
    Name = "web-server-security-group"
  }
}
