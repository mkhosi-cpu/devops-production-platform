# Root outputs now just re-expose the module's outputs.
output "vpc_id" {
  description = "The lab VPC ID"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs (ALB / internet-facing)"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs (app tier)"
  value       = module.network.private_subnet_ids
}

output "security_group_ids" {
  description = "Security group IDs by role"
  value       = module.network.security_group_ids
}
