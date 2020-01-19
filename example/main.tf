# Terraform configuration 
terraform {
  required_version = ">= 0.12"
}

#Provider configuration. Typically there will only be one provider config, unless working with multi account and / or multi region resources
provider "aws" {
  region = var.provider_region
}

###################
# S3 Bucket Module
###################

// Create the required S3 Bucket
module "demo_s3bucket" {
  source = "git@github.com:CloudMage-TF/AWS-S3Bucket-Module.git?ref=v1.0.2"

  // Required
  s3_bucket_name              = var.bucket_name
  
  // Optional
  // s3_bucket_region            = var.bucket_region
  // s3_bucket_prefix_list       = var.bucket_prefix
  // s3_bucket_suffix_list       = var.bucket_suffix
  // s3_versioning_enabled       = var.bucket_versioning
  // s3_mfa_delete               = var.bucket_mfa
  // s3_bucket_acl               = var.bucket_acl
  // s3_encryption_enabled       = var.bucket_encryption
  // s3_kms_key_arn              = var.bucket_cmk_arn
}
