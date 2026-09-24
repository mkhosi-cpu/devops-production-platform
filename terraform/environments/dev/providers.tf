provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "devops-production-platform"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}
