variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# PROD environment: SAME module, different inputs (different CIDR range, name_prefix).
# This is the whole point of Week 6/7 — reuse, not copy-paste.
module "network" {
  source = "../../modules/network"

  name_prefix = "devops-lab-prod"
  aws_region  = var.aws_region

  vpc_cidr              = "10.1.0.0/16"
  az_a                  = "us-east-1a"
  az_b                  = "us-east-1b"
  public_subnet_a_cidr  = "10.1.0.0/24"
  public_subnet_b_cidr  = "10.1.1.0/24"
  private_subnet_a_cidr = "10.1.10.0/24"
  private_subnet_b_cidr = "10.1.11.0/24"
  app_port              = 8080
}

output "vpc_id" {
  value = module.network.vpc_id
}
output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}
output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}
output "security_group_ids" {
  value = module.network.security_group_ids
}
