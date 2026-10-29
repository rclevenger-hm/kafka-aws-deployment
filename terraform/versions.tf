terraform {
  required_version = ">= 1.12.0, < 2.0.0"
  # Keep version attributes on separate lines so Dependabot can update them.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.67.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9.1"
    }
  }
  backend "s3" {}
}
provider "aws" {
  region = var.region
  default_tags { tags = local.tags }
}
