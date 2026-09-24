# A reusable module declares what it needs. Version constraints here are
# permissive (>=) so callers can pin the exact version in their root config.
terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
