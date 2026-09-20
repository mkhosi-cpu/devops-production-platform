# Inputs for the network module. Everything that varies between environments
# is a variable; nothing environment-specific is hard-coded inside the module.
variable "name_prefix" {
  description = "Prefix for named resources (e.g. devops-lab)"
  type        = string
}

variable "aws_region" {
  description = "Region (used to build the S3 endpoint service name)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "az_a" {
  description = "First availability zone"
  type        = string
}

variable "az_b" {
  description = "Second availability zone"
  type        = string
}

variable "public_subnet_a_cidr" {
  type = string
}
variable "public_subnet_b_cidr" {
  type = string
}
variable "private_subnet_a_cidr" {
  type = string
}
variable "private_subnet_b_cidr" {
  type = string
}

variable "app_port" {
  description = "Port the app listens on (allowed from the ALB SG)"
  type        = number
  default     = 8080
}
