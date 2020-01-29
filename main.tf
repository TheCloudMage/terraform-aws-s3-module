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
  region = "${var.s3_bucket_region != "empty" ? var.s3_bucket_region : data.aws_region.current.name}"

  // If a Prefix list was supplied then join it together, and append the passed bucket name.
  prefixed_bucket_name = <<EOS
%{~ if length(var.s3_bucket_prefix_list) > 0 ~}
${replace(replace(format("%s-%s", join("-", var.s3_bucket_prefix_list), var.s3_bucket_name), "region_prefix", local.region), "account_prefix", data.aws_caller_identity.current.account_id)}
%{~ else ~}
${var.s3_bucket_name}
%{~ endif ~}
EOS

// If a Suffix list was supplied then join it together, and prepend the already prefixed bucket name.
  suffixed_bucket_name = <<EOS
%{~ if length(var.s3_bucket_suffix_list) > 0 ~}
${replace(replace(format("%s-%s", local.prefixed_bucket_name, join("-", var.s3_bucket_suffix_list)), "region_suffix", local.region), "account_suffix", data.aws_caller_identity.current.account_id)}
%{~ else ~}
${local.prefixed_bucket_name}
%{~ endif ~}
EOS

  // Set the bucket name
  bucket_name = "${lower(local.suffixed_bucket_name)}"

}

######################
# S3 Bucket:           #
######################
// Although two blocks are specified, only one will be executed depending upon the var.s3_encryption_enabled setting.

// Encrypted
resource "aws_s3_bucket" "encrypted_bucket" {
  count        = var.s3_encryption_enabled == true ? 1 : 0
  region       = local.region
  bucket       = trimspace(local.bucket_name)
  acl          = var.s3_bucket_acl
  policy       = data.aws_iam_policy_document.this.json

  versioning { 
    enabled    = var.s3_versioning_enabled
    mfa_delete = var.s3_mfa_delete
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.s3_kms_key_arn == "AES256" ? "AES256" : "aws:kms"
        kms_master_key_id = var.s3_kms_key_arn != "AES256" ? var.s3_kms_key_arn : null
      }
    }
  }

  // Set the Name tag, and add Created_By, Creation_Date, and Creator_ARN tags with ignore change lifecycle policy.
  // Allow Updated_On to update on each exectuion.
  tags = merge(
    var.s3_bucket_tags,
    {
      Name            = lower(format("%s", trimspace(local.bucket_name))),
      Created_By      = data.aws_caller_identity.current.user_id
      Creator_ARN     = data.aws_caller_identity.current.arn
      Creation_Date   = timestamp()
      Updated_On      = timestamp()
      Encrypted       = format("%s", var.s3_encryption_enabled)
      CMK_ARN         = var.s3_kms_key_arn != "AES256" ? var.s3_kms_key_arn : "AWS KMS-AES256 aws/s3 Default Managed Key"
    }
  )

  lifecycle {
    ignore_changes = [tags["Created_By"], tags["Creation_Date"], tags["Creator_ARN"]]
  }

  // TODO:
    # logging
    # replication_configuration
}

// Not Encrypted
resource "aws_s3_bucket" "un_encrypted_bucket" {
  count        = var.s3_encryption_enabled == false ? 1 : 0
  region       = local.region
  bucket       = trimspace(local.bucket_name)
  acl          = var.s3_bucket_acl
  policy       = length(var.s3_shared_principal_list) > 0 ? data.aws_iam_policy_document.shared_access_bucket_policy.json : null

  versioning { 
    enabled    = var.s3_versioning_enabled
    mfa_delete = var.s3_mfa_delete
  }

  // Set the Name tag, and add Created_By, Creation_Date, and Creator_ARN tags with ignore change lifecycle policy.
  // Allow Updated_On to update on each exectuion.
  tags = merge(
    var.s3_bucket_tags,
    {
      Name            = lower(format("%s", trimspace(local.bucket_name))),
      Created_By      = data.aws_caller_identity.current.user_id
      Creator_ARN     = data.aws_caller_identity.current.arn
      Creation_Date   = timestamp()
      Updated_On      = timestamp()
      Encrypted       = format("%s", var.s3_encryption_enabled)
    }
  )

  lifecycle {
    ignore_changes = [tags["Created_By"], tags["Creation_Date"], tags["Creator_ARN"]]
  }

  // TODO:
    # logging
    # replication_configuration
}

#######################
# S3 Bucket Policies: #
#######################
// Construct the S3 Bucket Policy to deny the unencrypted transport of objects
data "aws_iam_policy_document" "encryption_in_transit_bucket_policy" {
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
}

// Construct the S3 Bucket Policy to allow access to shared accounts.
data "aws_iam_policy_document" "shared_access_bucket_policy" {
  statement {
    sid     = "AllowCrossAcctListAccess"

    effect  = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:ListBucketMultipartUploads"
    ]

    resources = [
      "arn:aws:s3:::${trimspace(local.bucket_name)}",
      "arn:aws:s3:::${trimspace(local.bucket_name)}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = length(var.s3_shared_principal_list) > 0 ? var.s3_shared_principal_list : ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid     = "AllowCrossAcctPUTAccess"

    effect  = "Allow"

    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:GetBucketVersioning",
      "s3:GetEncryptionConfiguration",
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:PutObjectRetention",
      "s3:RestoreObject"
    ]

    resources = [
      "arn:aws:s3:::${trimspace(local.bucket_name)}",
      "arn:aws:s3:::${trimspace(local.bucket_name)}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = length(var.s3_shared_principal_list) > 0 ? var.s3_shared_principal_list : ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

// Use policy overrides to evalute a new policy to pass to the next layer.
// This is essentially a dynamic conditional merge of the encryption_in_transit and shared_access bucket policies.
data "aws_iam_policy_document" "this" {
  source_json   = data.aws_iam_policy_document.encryption_in_transit_bucket_policy.json
  override_json = length(var.s3_shared_principal_list) > 0 ? data.aws_iam_policy_document.shared_access_bucket_policy.json : null
}