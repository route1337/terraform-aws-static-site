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

# Policy document for S3 CI/CD
data "aws_iam_policy_document" "static_site_cicd_policy" {
  statement {
    sid    = "${var.friendly_name}CICD"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.dns_name}",
      "arn:aws:s3:::www.${var.dns_name}",
      "arn:aws:s3:::${var.dns_name}/*",
      "arn:aws:s3:::www.${var.dns_name}/*"
    ]
  }
}

# IAM policy for CI/CD
resource "aws_iam_policy" "static_site_cicd_policy" {
  name        = "StaticSite${var.friendly_name}"
  path        = "/"
  description = "Allow management of the contents of S3 buckets related to hosting ${var.friendly_name}. Changing bucket settings, permissions, or deleting the buckets is not permitted."
  policy      = data.aws_iam_policy_document.static_site_cicd_policy.json
}

# Attach CI/CD policy to IAM group
resource "aws_iam_policy_attachment" "static_site_cicd_policy_attachment" {
  name       = "static-site-${var.friendly_name}-policy-attachment"
  policy_arn = aws_iam_policy.static_site_cicd_policy.arn
  groups     = [var.iam_group]
  users      = []
  roles      = []
}
