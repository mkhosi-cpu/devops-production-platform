terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Prod gets its OWN state key, fully separate from dev.
  backend "s3" {
    bucket       = "devops-lab-tfstate-23987ce5"
    key          = "env/prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
