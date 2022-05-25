terraform {
  backend "remote" {
    organization = "AmosOpsschool"

    workspaces {
      name = "AWS-and-Terraform"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile = "Amos-profile"
  region  = "us-east-1"
  
  default_tags {
    tags = {
      owner   = var.owner_tag
      Purpose = var.purpose_tag
    }
  }
}
