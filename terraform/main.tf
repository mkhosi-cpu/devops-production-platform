# Root config: call the network module with this environment's values.
# All the resource detail now lives in modules/network; this is just the "wiring".
module "network" {
  source = "./modules/network"

  name_prefix = "devops-lab"
  aws_region  = var.aws_region

  vpc_cidr              = "10.0.0.0/16"
  az_a                  = "us-east-1a"
  az_b                  = "us-east-1b"
  public_subnet_a_cidr  = "10.0.0.0/24"
  public_subnet_b_cidr  = "10.0.1.0/24"
  private_subnet_a_cidr = "10.0.10.0/24"
  private_subnet_b_cidr = "10.0.11.0/24"
  app_port              = 8080
}
