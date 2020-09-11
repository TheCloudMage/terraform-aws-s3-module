# Terraform configuration 
terraform {
  required_version = ">= 0.13"
}

#Provider configuration. Typically there will only be one provider config, unless working with multi account and / or multi region resources
provider "aws" {
  region = var.provider_region
}

# Test Bucket Policy
data "aws_iam_policy_document" "test_policy" {
  statement {
    actions = [
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:AbortMultipartUpload"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::123456789101:role/AWS-S3W-Role"]
    }

    resources = [
      "%BUCKET%",
      "%BUCKET%/*",
    ]
  }
}
