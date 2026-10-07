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

# Use the default VPC so we don't create extra network resources
data "aws_vpc" "default" {
  default = true
}

# Latest Ubuntu 22.04 image
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_security_group" "app" {
  name        = "${var.project_name}-sg"
  description = "SSH from my IP, app port open"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH (my IP only)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    description = "App port"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type # t2.micro = free tier (new accounts)
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.app.id]

  # Installs Docker on first boot (no secrets here)
  user_data = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io
    systemctl enable --now docker
    usermod -aG docker ubuntu
  EOT

  tags = {
    Name = "${var.project_name}-ec2"
  }
}
