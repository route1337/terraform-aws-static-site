Terraform Module - AWS Static Site
==================================
This repo contains the Terraform module for deploying a static website via S3, CloudFront, ACM, and Route53.

Infrastructure Created
----------------------
The following infrastructure is created using this module:

1. An S3 bucket named after the DNS name of your website that redirects to your website on the www subdomain.
2. An S3 bucket named after the DNS name of your website with the www subdomain.
3. A CloudFront distribution for both S3 buckets.
4. An ACM certificate to secure both CloudFront distributions.
5. Route53 records to host your website.
6. A Lambda@Edge function to provide decent security headers for the site.

Variables
---------
The following variables are required.

```hcl
module "static-site" {
  source                  = "git::https://github.com/route1337/terraform-aws-static-site"
  friendly_name               = "example-com" // A friendly name for your site that can be used in IAM policy names
  dns_name                  = "example.com"
  zone_id         = "ZONE_ID" // The Route53 Zone ID that this domain is hosted in
  iam_group = "cicd-cluster" // An IAM group that will be given access to manage the S3 contents
  tags = {
    SomeTag = "SomeValue"
  }
  enable_auth = true // OPTIONAL: function to enable authentication via Lambda@Edge
  auth_lambda = "arn:aws:lambda:us-east-1:XXXXXXX:function:basic-auth:1" // REQUIRED with enable_auth: Lambda@Edge Qualified ARN for basic authentication 
}
```

Testing
-------
This module is fully tested AWS in a live environment.  
[TESTING.md](TESTING.md) contains details and instructions for testing. 

Donate To Support This Terraform Module
---------------------------------------
Route 1337 LLC's open source code heavily relies on donations. If you find this Terraform module useful, please consider using the GitHub Sponsors button to show your continued support.

Thank you for your support!
