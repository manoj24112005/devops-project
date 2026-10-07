variable "aws_region" {
  type        = string
  description = "AWS region for EC2 deployment"
  default     = "eu-north-1"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "AWS EC2 Key Pair name for SSH access"
  default     = "devops-project-key"
}

variable "my_ip_cidr" {
  type        = string
  description = "CIDR block for SSH access (default 0.0.0.0/0 for classroom/demo accessibility)"
  default     = "0.0.0.0/0"
}

variable "project_name" {
  type        = string
  description = "Project resource tag name"
  default     = "devops-project"
}
