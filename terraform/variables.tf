# Input variables let us parameterize the config instead of hard-coding values.
variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}
