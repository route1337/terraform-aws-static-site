#
# Project:: Terraform Module - static-site
#
# Copyright 2021, Route 1337, LLC, All Rights Reserved.
#
# Maintainers:
# - Matthew Ahrenstein: matthew@route1337.com
#
# See LICENSE
#

### The CloudFront Distributions here are only used if authentication is not enabled ###

### www Distribution ###
resource "aws_cloudfront_distribution" "static_site" {
  # Only include the resource is var.enable_auth is not used
  count = var.enable_auth ? 0 : 1

  aliases             = ["www.${var.dns_name}"]
  comment             = "${var.friendly_name} Website"
  enabled             = true
  price_class         = "PriceClass_100"
  default_root_object = "index.html"
  http_version        = "http2"
  is_ipv6_enabled     = true

  origin {
    domain_name = aws_s3_bucket.www_static_site.website_endpoint
    origin_id   = "StaticS3-Endpoint-${var.friendly_name}"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_keepalive_timeout = 5
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }
  default_cache_behavior {

    # Security Headers
    lambda_function_association {
      event_type = "origin-response"
      lambda_arn = aws_lambda_function.static_site_security_headers.qualified_arn
    }

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = false
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    smooth_streaming       = false
    target_origin_id       = "StaticS3-Endpoint-${var.friendly_name}"
    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.static_site.arn
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method       = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = local.tags

  depends_on = [aws_acm_certificate.static_site]
}

### www Redirect Distribution ###
resource "aws_cloudfront_distribution" "static_site_redirect" {
  # Only include the resource is var.enable_auth is not used
  count = var.enable_auth ? 0 : 1

  aliases         = [var.dns_name]
  comment         = "${var.friendly_name} WWW Redirect"
  enabled         = true
  price_class     = "PriceClass_100"
  http_version    = "http2"
  is_ipv6_enabled = true

  origin {
    domain_name = aws_s3_bucket.static_site.website_endpoint
    origin_id   = "S3-WWWRedirect-${var.friendly_name}"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_keepalive_timeout = 5
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }
  default_cache_behavior {

    # Security Headers
    lambda_function_association {
      event_type = "origin-response"
      lambda_arn = aws_lambda_function.static_site_security_headers.qualified_arn
    }

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = false
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    smooth_streaming       = false
    target_origin_id       = "S3-WWWRedirect-${var.friendly_name}"
    viewer_protocol_policy = "allow-all"
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.static_site.arn
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method       = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = local.tags

  depends_on = [aws_acm_certificate.static_site]
}
