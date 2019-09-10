output "cloudfront_distribution_domain_name" {
  value = module.s3_static_website_cloudfront_distribution.cloudfront_distribution_domain_name
}

output "route53_domain_record_fqdn" {
  value = module.s3_static_website_cloudfront_distribution.route53_domain_record_fqdn
}
