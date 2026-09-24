provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "devops-production-platform"
      Environment = "prod"
      ManagedBy   = "terraform"
    }
  }
}
