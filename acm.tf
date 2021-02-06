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

# Certificate request for www and apex
resource "aws_acm_certificate" "static_site" {
  domain_name               = "www.${var.dns_name}"
  subject_alternative_names = [var.dns_name]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

# Certificate Validation
resource "aws_acm_certificate_validation" "static_site" {
  certificate_arn         = aws_acm_certificate.static_site.arn
  validation_record_fqdns = [for record in aws_route53_record.static_site_acm_validate : record.fqdn]
}

# ACM DNS Validation Record Apex
resource "aws_route53_record" "static_site_acm_validate" {
  for_each = {
    for dvo in aws_acm_certificate.static_site.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  zone_id         = var.zone_id
  records         = [each.value.record]
  ttl             = 60
}
