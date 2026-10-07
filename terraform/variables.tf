variable "region" {
  default = "ap-south-1"
}
variable "project_name" {
  default = "student-devops"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "key_name" {
  description = "Name of an existing AWS key pair (created in AWS console)"
  type        = string
}
variable "my_ip_cidr" {
  description = "Your public IP for SSH, like 1.2.3.4/32"
  type        = string
}
variable "app_port" {
  default = 5000
}
