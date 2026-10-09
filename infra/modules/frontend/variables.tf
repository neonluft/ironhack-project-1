
# Fetch Latest Ubuntu 22.04 Image
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "frontend_security_group_id" {
  type = list(string)
}

variable "key_name" {
  type = string
}

variable "student_name" {
  type = string
}