# Outputs = the module's public interface. Callers use these instead of
# reaching into the module's internals.
output "vpc_id" {
  value = aws_vpc.lab.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "private_subnet_ids" {
  value = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "security_group_ids" {
  value = {
    alb   = aws_security_group.alb.id
    app   = aws_security_group.app.id
    admin = aws_security_group.admin.id
  }
}
