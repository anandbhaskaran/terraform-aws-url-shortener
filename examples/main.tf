provider "aws" {
  region = "eu-west-1"
}

module "url_shortener" {
  source  = "anandbhaskaran/url-shortener/aws"
  version = "1.2.0"
}