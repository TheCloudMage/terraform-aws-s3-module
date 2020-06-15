# Terraform configuration 
terraform {
  required_version = ">= 0.12"
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
        type = "AWS"
        identifiers = ["arn:aws:iam::123456789101:role/AWS-S3W-Role"]
    }

    resources = [
        "%BUCKET%",
        "%BUCKET%/*",
    ]
  }
}

###################
# S3 Bucket Module
###################

// Default Bucket Test
module "defaults" {
  source = "../"

    bucket = var.bucket

    tags = {
      Provisioned_By = "Terraform"
      Module_GitHub_URL = "https://github.com/CloudMage-TF/AWS-S3Bucket-Module.git"
    }
}

// Bucket Naming Tests
module "naming" {
  source = "../"

    bucket        = var.bucket
    region        = "us-west-2"
    bucket_prefix = ["account_prefix", "yes"]
    bucket_suffix = ["region_suffix", "42"]
    versioning    = true
    mfa_delete    = true
    read_access = ["arn:aws:iam::123456789101:role/AWS-S3RO-Role"]
}

// Bucket Encryption Test with Default Key
module "default_encryption" {
  source = "../"

    bucket        = var.bucket
    region        = "us-east-1"
    encryption    = true
    write_access      = ["arn:aws:iam::123456789101:role/AWS-S3W-Role"]
}

// Bucket Encryption Test with CMK
module "cmk_encryption" {
  source = "../"

    bucket            = var.bucket
    region            = "us-east-1"
    acl               = "public-read"
    encryption        = true
    kms_master_key_id = "arn:aws:kms:us-east-1:123456789101:key/127ab3c4-de5f-6e7d-898c-7ba6b5432abc"
    policy         = data.aws_iam_policy_document.test_policy.json
}

// Bucket Logging
module "logging" {
  source = "../"

    bucket          = var.bucket
    region          = "us-east-1"
    logging_bucket  = "test-logging-bucket-configuration-test"
    policy          = data.aws_iam_policy_document.test_policy.json
    policy_override = true
}

// Bucket Static Hosting
module "hosting" {
  source = "../"

    bucket         = var.bucket
    region         = "us-east-1"
    static_hosting = true
    index_document = "index.py"
    error_document = "error.py"

    cors_rule = {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "PUT", "POST"]
      allowed_origins = ["*"]
      expose_headers  = []
      max_age_seconds = "1500"
    }
}

// Bucket Static Hosting
module "disabled" {
  source = "../"

    bucket          = var.bucket
    region          = "us-east-1"
    module_disabled = true
}
