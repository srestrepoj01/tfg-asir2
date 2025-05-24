provider "aws" {
  region = "eu-west-3"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "mastodon-terraform-state-paris"
    key    = "infra/terraform.tfstate"
    region = "eu-west-3"
    encrypt = true
  }
}
