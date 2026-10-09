terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # Restricts updates to minor versions only
    }
  }
  backend "s3" {
    bucket         = "florik-project1-state-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "florik-project1-state-lock"

  }
}

provider "aws" {
  region = "us-east-1"
}