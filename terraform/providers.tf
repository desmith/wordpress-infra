terraform {
  required_version = ">= 1.9"

  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us_east_1"

  default_tags {
    tags = {
      Environment = var.env
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}
