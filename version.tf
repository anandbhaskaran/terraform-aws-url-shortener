terraform {
  required_version = ">= 0.12.0"

  required_providers {
    aws  = ">= 3.6"
    null = "~> 2.0"
  }
}

provider "aws" {
  region = "eu-west-1"
}