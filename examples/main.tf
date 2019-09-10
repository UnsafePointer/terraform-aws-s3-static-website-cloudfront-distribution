provider "aws" {
  region = "us-east-1"
}

module "s3_static_website_cloudfront_distribution" {
  source = "./.."
  domain = "rubyps.one"
}
