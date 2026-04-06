terraform {
  required_version = ">= 1.12.0, < 2.0.0"
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 6.67.0" }
    random = { source = "hashicorp/random", version = "~> 3.7.2" }
  }
  backend "s3" {}
}
provider "aws" {
  region = var.region
  default_tags { tags = local.tags }
}
