terraform {
  backend "s3" {
      bucket  = "amos-remote-state-terraform"
      key     = "backend.tfstate"
      region  = "us-east-1"
      profile = "Amos-profile"
  }
}