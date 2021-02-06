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

locals {
  base_tags = {
    "Module" = "true"
  }
  tags = merge(local.base_tags, var.tags)
}

variable "friendly_name" {
  type        = string
  description = "REQUIRED: A name that does not contain characters that are invalid in AWS resource names like IAM users"
}

variable "dns_name" {
  type        = string
  description = "REQUIRED: The DNS name of the site (Do not add \"www\".)"
}

variable "zone_id" {
  type        = string
  description = "REQUIRED: Route53 Zone ID of the zone the site will use for deployment"
}

variable "iam_group" {
  type        = string
  description = "REQUIRED: Name of an IAM group to grant CI/CD access to"
}

variable "tags" {
  type        = map(string)
  description = "REQUIRED: You should have a group of tags such as \"CostTracking\""
}

variable "enable_auth" {
  type        = bool
  description = "OPTIONAL: Enable authentication via a Lambda@Edge function"
  default     = false
}

variable "auth_lambda" {
  type        = string
  description = "REQUIRED with enable_auth: The Qualified ARN of a Lambda@Edge function to use for basic auth"
  default     = ""
}
