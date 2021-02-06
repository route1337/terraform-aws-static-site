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

data "aws_iam_policy_document" "static_site_s3_bucket_policy" {
  statement {
    sid       = "AllowCloudFrontToReadFromBucket"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::www.${var.dns_name}/*"]

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    condition {
      test     = "StringEqualsIgnoreCase"
      variable = "aws:UserAgent"
      values   = ["Amazon CloudFront"]
    }
  }
}

resource "aws_s3_bucket" "static_site" {
  bucket        = var.dns_name
  acl           = "private"
  force_destroy = false

  tags = local.tags

  versioning {
    enabled    = false
    mfa_delete = false
  }

  website {
    redirect_all_requests_to = "www.${var.dns_name}"
  }
}

resource "aws_s3_bucket" "www_static_site" {
  bucket        = "www.${var.dns_name}"
  force_destroy = false
  acl           = "private"

  tags = local.tags

  versioning {
    enabled    = false
    mfa_delete = false
  }

  website {
    error_document = "404.html"
    index_document = "index.html"
  }

  policy = data.aws_iam_policy_document.static_site_s3_bucket_policy.json
}
