output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.website_distribution.domain_name
}

output "route53_domain_record_fqdn" {
  value = aws_route53_record.domain_record.fqdn
}
