terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # backend "s3" {
  #   bucket = "terraform-state-bucket"
  #   key    = "three-tier/terraform.tfstate"
  #   region = "ap-southeast-1"
  # }
}

provider "aws" {
  region = "ap-southeast-1"
}
