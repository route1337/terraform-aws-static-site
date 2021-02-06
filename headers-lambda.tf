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

# IAM role for Lambda@Edge to assume role
resource "aws_iam_role" "static_site_lambda_at_edge" {
  name               = "static-site-${var.friendly_name}-lambda-at-edge"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Attach the Basic Execution permissions
resource "aws_iam_role_policy_attachment" "static_site_lambda_at_edge" {
  role       = aws_iam_role.static_site_lambda_at_edge.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# IAM Policy for AWS CloudWatch logging
data "aws_iam_policy_document" "static_site_lambda_at_edge_logging" {
  statement {
    sid = "CloudWatchLogging"
    actions = ["logs:CreateLogGroup",
      "logs:CreateLogStream",
    "logs:PutLogEvents"]

    resources = ["arn:aws:logs:*:*:*"]
    effect    = "Allow"
  }
}

# Create the IAM policy for CloudWatch logging
resource "aws_iam_policy" "static_site_lambda_at_edge_logging" {
  name        = "static-site-${var.friendly_name}-lambda-at-edge-logging"
  description = "${var.friendly_name} CloudWatch permissions for Lambda At Edge"
  policy      = data.aws_iam_policy_document.static_site_lambda_at_edge_logging.json
}

# Attach the CloudWatch Logging permissions
resource "aws_iam_policy_attachment" "static_site_lambda_at_edge_logging" {
  name       = "static-site-${var.friendly_name}-lambda-at-edge-logging"
  roles      = [aws_iam_role.static_site_lambda_at_edge.name]
  policy_arn = aws_iam_policy.static_site_lambda_at_edge_logging.arn
}

# Template file for determining security headers
data "template_file" "static_site_security_headers" {
  template = file("${path.module}/static-site-security-headers.js.tpl")
}

# Create a zip of the lambda function
data "archive_file" "static_site_security_headers_zip" {
  type = "zip"

  output_path             = "static-site-security-headers-lambda.zip"
  source_content          = data.template_file.static_site_security_headers.rendered
  source_content_filename = "static-site-security-headers.js"
}

# Deploy the AWS Lambda function
resource "aws_lambda_function" "static_site_security_headers" {
  filename         = "static-site-security-headers-lambda.zip"
  function_name    = "static-site-${var.friendly_name}-security-headers"
  role             = aws_iam_role.static_site_lambda_at_edge.arn
  handler          = "static-site-security-headers.handler"
  source_code_hash = data.archive_file.static_site_security_headers_zip.output_base64sha256
  runtime          = "nodejs10.x"
  memory_size      = 128
  timeout          = 3
  publish          = true

  tags = local.tags
}
