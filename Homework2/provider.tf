terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile = "Amos-Profile"
  region  = "us-east-1"
  assume_role {
  role_arn = "arn:aws:iam::459468923771:role/admin-for-terraform"
  }
  
  default_tags {
    tags = {
      owner   = var.owner_tag
      Purpose = var.purpose_tag
    }
  }
}
