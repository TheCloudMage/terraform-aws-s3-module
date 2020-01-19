######################
# Data Sources:      #
######################
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

######################
# Local Variables:   #
######################
locals {
  // Set local region variable by either taking a passed value or by quering the data source.
  region         = "${var.s3_bucket_region != "empty" ? var.s3_bucket_region : data.aws_region.current.name}"
  
  // If a Prefix list was supplied then join it together, and append the passed bucket name.
  prefixed_bucket_name  = <<EOS
%{~ if length(var.s3_bucket_prefix_list) > 0 ~}
${replace(replace(format("%s-%s", join("-", var.s3_bucket_prefix_list), var.s3_bucket_name), "region_prefix", local.region), "account_prefix", data.aws_caller_identity.current.account_id)}
%{~ else ~}
${var.s3_bucket_name}
%{~ endif ~}
EOS

// If a Suffix list was supplied then join it together, and prepend the already prefixed bucket name.
  suffixed_bucket_name  = <<EOS
%{~ if length(var.s3_bucket_suffix_list) > 0 ~}
${replace(replace(format("%s-%s", local.prefixed_bucket_name, join("-", var.s3_bucket_suffix_list)), "region_suffix", local.region), "account_suffix", data.aws_caller_identity.current.account_id)}
%{~ else ~}
${local.prefixed_bucket_name}
%{~ endif ~}
EOS

  // Set the bucket name
  bucket_name          = "${lower(local.suffixed_bucket_name)}"

}

######################
# S3 Bucket:           #
######################
// Although 2 blocks are specified, only 1 will be exectued depandant upon the var.s3_encryption_enabled setting

// Encrypted
resource "aws_s3_bucket" "encrypted_bucket" {
  count = "${var.s3_encryption_enabled == true ? 1 : 0}"
  region                               = local.region
  bucket                               = trimspace(local.bucket_name)
  acl                                  = var.s3_bucket_acl
  policy                               = data.aws_iam_policy_document.this.json
  
  versioning { 
    enabled    = var.s3_versioning_enabled
    mfa_delete = var.s3_mfa_delete
  }
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "${var.s3_kms_key_arn == "AES256" ? "AES256" : "aws:kms"}"
        kms_master_key_id = "${var.s3_kms_key_arn != "AES256" ? var.s3_kms_key_arn : null}"
      }
    }
  }

  // TODO:
    //logging
    // replication_configuration
    //tags
}

// Not Encrypted
resource "aws_s3_bucket" "un_encrypted_bucket" {
  count = "${var.s3_encryption_enabled == false ? 1 : 0}"
  region                               = local.region
  bucket                               = trimspace(local.bucket_name)
  acl                                  = var.s3_bucket_acl
  
  versioning { 
    enabled    = var.s3_versioning_enabled
    mfa_delete = var.s3_mfa_delete
  }
  
  // TODO:
    //logging
    // replication_configuration
    //tags
}

######################
# S3 Policy:         #
######################
// Construct the S3 Bucket Policy to be applied to the bucket

data "aws_iam_policy_document" "this" {
  // Deny UnEncrypted Transport of Objects
  statement {
    sid     = "DenyNonSecureTransport"

    effect  = "Deny"

    actions = [
      "s3:*"
    ]

    resources = [
      "arn:aws:s3:::${trimspace(local.bucket_name)}",
      "arn:aws:s3:::${trimspace(local.bucket_name)}/*",
      ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test       = "Bool"
      variable   = "aws:SecureTransport"

      values     = [
        "false"
      ]
    }
  }

  // Deny PutObject if Encryption Method/Key is not specified
  statement {
    sid     = "DenyIncorrectEncryptionHeader"

    effect  = "Deny"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::${trimspace(local.bucket_name)}",
      "arn:aws:s3:::${trimspace(local.bucket_name)}/*",
      ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test       = "StringNotEquals"
      variable   = "s3:x-amz-server-side-encryption"

      values     = [
        "aws:kms",
        "AES256"
      ]
    }
  }

  // Deny PutObject if serverside Encryption is not specifed in the put header
  statement {
    sid     = "DenyUnEncryptedObjectUploads"

    effect  = "Deny"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::${trimspace(local.bucket_name)}",
      "arn:aws:s3:::${trimspace(local.bucket_name)}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test       = "Null"
      variable   = "s3:x-amz-server-side-encryption"

      values     = [
        "true"
      ]
    }
  }
}
