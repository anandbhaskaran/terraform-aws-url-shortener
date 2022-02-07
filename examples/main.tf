provider "aws" {
  region = "eu-west-1"
}

module "url-shortener" {
  source  = "anandbhaskaran/url-shortener/aws"
  version = "1.0.0"
}