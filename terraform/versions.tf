# The `terraform` block configures Terraform itself (not AWS resources).
terraform {
  # Pin the Terraform CLI version. `use_lockfile` (native S3 locking) needs >= 1.10.
  required_version = ">= 1.10"

  # Declare which providers this config uses and pin their versions.
  # A "provider" is the plugin that knows how to talk to a specific API (here, AWS).
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # any 5.x release
    }
  }

  # Where Terraform stores its STATE (its record of what it manages).
  # S3 = durable + versioned; encrypt = at rest; use_lockfile = a lock object in S3
  # so two runs can't write state at the same time (no DynamoDB needed on TF >= 1.10).
  backend "s3" {
    bucket       = "devops-lab-tfstate-23987ce5"
    key          = "network/terraform.tfstate" # path of the state file within the bucket
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
