# --- resource ---
variable "region" {
    description = "value of region"
    type = string
    default = "eu-north-1"
}

variable "ami" {
  description = "AMI ID"
  type = string
  default = "ami-0c1ac8a41498c1a9c"
}

variable "instance_type" {
  description = "type of instance"
  type = string
  default = "t3.micro"
}

variable "key_name" {
  description = "keypair name"
  type = string
  default = "eu-stockholm"
}



