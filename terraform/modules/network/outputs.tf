# Outputs = the module's public interface. Callers use these instead of
# reaching into the module's internals.
output "vpc_id" {
  description = "The VPC ID"
  value       = aws_vpc.lab.id
}

output "public_subnet_ids" {
  description = "The two public subnet IDs (ALB / internet-facing tier)"
  value       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "private_subnet_ids" {
  description = "The two private subnet IDs (app tier)"
  value       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "security_group_ids" {
  description = "Security group IDs by role: alb / app / admin"
  value = {
    alb   = aws_security_group.alb.id
    app   = aws_security_group.app.id
    admin = aws_security_group.admin.id
  }
}
