# Configure the AWS provider — this tells Terraform which region to operate in.
# Credentials are NOT set here; the provider automatically uses the same ones the
# AWS CLI uses (~/.aws/credentials — currently ITAdmin). Keys never live in code.
provider "aws" {
  region = var.aws_region

  # default_tags are merged onto every resource this provider manages, so the whole
  # platform is filterable by project / environment / owner without tagging each
  # resource by hand.
  default_tags {
    tags = {
      Project     = "devops-production-platform"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}
