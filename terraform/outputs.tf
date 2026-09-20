# Outputs expose selected values after apply (visible via `terraform output`),
# handy for humans and for wiring other configs to this network.
output "vpc_id" {
  description = "The lab VPC ID"
  value       = aws_vpc.lab.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs (ALB / internet-facing)"
  value       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs (app tier)"
  value       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "security_group_ids" {
  description = "Security group IDs by role"
  value = {
    alb   = aws_security_group.alb.id
    app   = aws_security_group.app.id
    admin = aws_security_group.admin.id
  }
}
