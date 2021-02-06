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

### The Route 53 records here are only used if authentication is enabled ###

# A record for the redirect to WWW
resource "aws_route53_record" "auth_static_site_A" {
  # Only include the resource is var.enable_auth
  count = var.enable_auth ? 1 : 0

  zone_id = var.zone_id
  name    = var.dns_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.auth_static_site_redirect[0].domain_name
    zone_id                = aws_cloudfront_distribution.auth_static_site_redirect[0].hosted_zone_id
    evaluate_target_health = false
  }
}

# AAAA record for the redirect to WWW
resource "aws_route53_record" "auth_static_site_AAAA" {
  # Only include the resource is var.enable_auth
  count = var.enable_auth ? 1 : 0

  zone_id = var.zone_id
  name    = var.dns_name
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.auth_static_site_redirect[0].domain_name
    zone_id                = aws_cloudfront_distribution.auth_static_site_redirect[0].hosted_zone_id
    evaluate_target_health = false
  }
}

# A record for the WWW site
resource "aws_route53_record" "auth_www_static_site_A" {
  # Only include the resource is var.enable_auth
  count = var.enable_auth ? 1 : 0

  zone_id = var.zone_id
  name    = "www.${var.dns_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.auth_static_site[0].domain_name
    zone_id                = aws_cloudfront_distribution.auth_static_site[0].hosted_zone_id
    evaluate_target_health = false
  }
}

# AAAA record for the WWW site
resource "aws_route53_record" "auth_www_static_site_AAAA" {
  # Only include the resource is var.enable_auth
  count = var.enable_auth ? 1 : 0

  zone_id = var.zone_id
  name    = "www.${var.dns_name}"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.auth_static_site[0].domain_name
    zone_id                = aws_cloudfront_distribution.auth_static_site[0].hosted_zone_id
    evaluate_target_health = false
  }
}
