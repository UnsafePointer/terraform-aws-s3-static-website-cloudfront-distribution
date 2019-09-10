# terraform-aws-s3-static-website-cloudfront-distribution

Terraform module to create an AWS CloudFront distribution serving an static website hosted on AWS S3 with SSL managed by AWS ACM

> The specified SSL certificate doesn't exist, isn't in us-east-1 region, isn't valid, or doesn't include a valid certificate chain.

Note that you can only use ACM certificates from the us-east-1 region when configuring CloudFront with ACM, so effectively, this module only works on us-east-1.
