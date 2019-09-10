# S3

resource "aws_s3_bucket" "website_bucket" {
  bucket = "${var.domain}"
  acl    = "public-read"
  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${var.domain}/*"]
    }
  ]
}
POLICY
  website {
    index_document = "index.html"
  }
}

# ACM

resource "aws_acm_certificate" "ssl_certificate" {
  domain_name = "*.${var.domain}"
  validation_method = "DNS"
  subject_alternative_names = ["${var.domain}"]
}

resource "aws_acm_certificate_validation" "ssl_certificate_validation" {
  certificate_arn = "${aws_acm_certificate.ssl_certificate.arn}"
  validation_record_fqdns = ["${aws_route53_record.ssl_certificate_validation_record.fqdn}"]
}

# Route53

resource "aws_route53_zone" "public_hosted_zone" {
  name = "${var.domain}"
}

resource "aws_route53_record" "ssl_certificate_validation_record" {
  name = "${aws_acm_certificate.ssl_certificate.domain_validation_options.0.resource_record_name}"
  type = "${aws_acm_certificate.ssl_certificate.domain_validation_options.0.resource_record_type}"
  zone_id = "${aws_route53_zone.public_hosted_zone.id}"
  records = ["${aws_acm_certificate.ssl_certificate.domain_validation_options.0.resource_record_value}"]
  ttl = 60
}

resource "aws_route53_record" "domain_record" {
  zone_id = "${aws_route53_zone.public_hosted_zone.zone_id}"
  name = "${var.domain}"
  type = "A"

  alias {
    name = "${aws_cloudfront_distribution.website_distribution.domain_name}"
    zone_id = "${aws_cloudfront_distribution.website_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}

# CloudFront

resource "aws_cloudfront_distribution" "website_distribution" {
  origin {
    custom_origin_config {
      http_port = "80"
      https_port = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    domain_name = "${aws_s3_bucket.website_bucket.website_endpoint}"
    origin_id = "${var.domain}"
  }

  enabled = true
  default_root_object = "index.html"

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress = true
    allowed_methods = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = "${var.domain}"
    min_ttl = 0
    default_ttl = 86400
    max_ttl = 31536000

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  aliases = ["${var.domain}"]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate.ssl_certificate.arn}"
    ssl_support_method = "sni-only"
  }
}

