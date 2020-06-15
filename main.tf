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
  region = "${var.region != null ? var.region : data.aws_region.current.name}"

  // If a Prefix list was supplied then join it together, and append the passed bucket name.
  prefixed_bucket_name = <<EOS
%{~ if length(var.bucket_prefix) > 0 ~}
${replace(replace(format("%s-%s", join("-", var.bucket_prefix), var.bucket), "region_prefix", local.region), "account_prefix", data.aws_caller_identity.current.account_id)}
%{~ else ~}
${var.bucket}
%{~ endif ~}
EOS

// If a Suffix list was supplied then join it together, and prepend the already prefixed bucket name.
  suffixed_bucket_name = <<EOS
%{~ if length(var.bucket_suffix) > 0 ~}
${replace(replace(format("%s-%s", local.prefixed_bucket_name, join("-", var.bucket_suffix)), "region_suffix", local.region), "account_suffix", data.aws_caller_identity.current.account_id)}
%{~ else ~}
${local.prefixed_bucket_name}
%{~ endif ~}
EOS

  // Set the bucket name
  bucket_name = trimspace(lower(local.suffixed_bucket_name))

  // Bucket name to hold S3 access logs (buckets are in AccountBaseline)
  log_bucket_name = var.logging_bucket != null ? trimspace(lower(var.logging_bucket)) : null

  // Set Encryption Setting
  sse_algorithm = var.kms_master_key_id == "AES256" ? "AES256" : "aws:kms"
}

######################
# S3 Bucket:           #
######################
// Although two blocks are specified, only one will be executed depending upon the var.encryption setting.

// Encrypted
resource "aws_s3_bucket" "this" {
  count        = var.module_enabled ? 1 : 0

  region       = local.region
  bucket       = local.bucket_name
  acl          = var.acl
  policy       = data.aws_iam_policy_document.this.json

  // Bucket Versioning
  versioning { 
    enabled    = var.versioning
    mfa_delete = var.mfa_delete
  }

  // Bucket Logging
  dynamic "logging" {
    for_each = var.log_bucket_name =! null ? toset(["${var.log_bucket_name}"]) : toset([])
    content {
      target_bucket = logging.value
      target_prefix = "${local.bucket_name}/"
    }
  }

  // Server Sided Encryption
  dynamic "server_side_encryption_configuration" {
    for_each = var.encryption ? toset(["${local.sse_algorithm}"]) : toset([])
    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm     = server_side_encryption_configuration.value
          kms_master_key_id = local.sse_algorithm != "AES256" ? local.sse_algorithm : null
        }
      }
    }
  }

  // Web Hosting
  dynamic "website" {
    for_each = var.static_hosting ? toset(["${var.index_document}"]) : toset([])
    content {
      index_document = website.value
      error_document = var.error_document
    }
  }

  // CORS Configuration
  dynamic "cors_rule" {
    for_each = keys(var.cors_rule) ? toset([1]) : toset([])
    content {
      allowed_headers = coalesce(cors_rule.value.allowed_headers, [])
      allowed_methods = coalesce(cors_rule.value.allowed_methods, [])
      allowed_origins = coalesce(cors_rule.value.allowed_origins, [])
      expose_headers = coalesce(cors_rule.value.expose_headers, [])
      max_age_seconds = coalesce(cors_rule.value.max_age_seconds, 3000)
    }
  }

  // Set the Name tag, and add Created_By, Creation_Date, and Creator_ARN tags with ignore change lifecycle policy.
  // Allow Updated_On to update on each exectuion.
  tags = merge(
    var.tags,
    {
      Name            = local.bucket_name,
      Created_By      = data.aws_caller_identity.current.user_id
      Creator_ARN     = data.aws_caller_identity.current.arn
      Creation_Date   = timestamp()
      Updated_On      = timestamp()
      Encrypted       = format("%s", var.encryption)
      CMK_ARN         = local.sse_algorithm != "AES256" ? local.sse_algorithm : "AWS KMS-AES256 aws/s3 Default Managed Key"
    }
  )

  lifecycle {
    ignore_changes = [tags["Created_By"], tags["Creation_Date"], tags["Creator_ARN"]]
  }

  // TODO:
    # LifeCycle Policies
    # Replication Configuration
}

#######################
# S3 Bucket Policies: #
#######################
// Construct the S3 Bucket Policy to deny the unencrypted transport of objects
data "aws_iam_policy_document" "encryption_in_transit" {
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

// S3 Read Only Access Policy
data "aws_iam_policy_document" "read_access" {
  statement {
    sid     = "ReadAccess"
    effect  = "Allow"
    actions = [
      "s3:HeadBucket",
      "s3:ListBucket*",
      "s3:ListAllMyBuckets",
      "s3:ListBucketVersions",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning",
      "s3:GetEncryptionConfiguration",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::${trimspace(local.bucket_name)}",
      "arn:aws:s3:::${trimspace(local.bucket_name)}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = length(var.var.read_access) > 0 ? var.var.read_access : ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

// S3 Write Access Policy
data "aws_iam_policy_document" "write_access" {
  statement {
    sid     = "WriteAccess"
    effect  = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:PutObject",
      "s3:PutObjectRetention",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:RestoreObject"
    ]

    resources = [
      "arn:aws:s3:::${trimspace(local.bucket_name)}",
      "arn:aws:s3:::${trimspace(local.bucket_name)}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = length(var.var.write_access) > 0 ? var.var.write_access : ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

// Use policy overrides to evalute a new policy to pass to the next layer.
// This is essentially a dynamic conditional merge of the encryption_in_transit, read, write, and custom policies.
data "aws_iam_policy_document" "read_policy" {
  count         = var.module_enabled ? 1 : 0
  source_json   = data.aws_iam_policy_document.encryption_in_transit.json
  override_json = length(var.read_access) > 0 ? data.aws_iam_policy_document.read_access.json : null
}

data "aws_iam_policy_document" "write_policy" {
  count         = var.module_enabled ? 1 : 0
  source_json   = data.aws_iam_policy_document.read_policy[0].json
  override_json = length(var.write_access) > 0 ? data.aws_iam_policy_document.write_access.json : null
}

data "aws_iam_policy_document" "custom_policy" {
  count         = var.module_enabled ? 1 : 0
  source_json   = data.aws_iam_policy_document.write_policy[0].json
  override_json = var.policy != null ? replace(var.policy, "%BUCKET%", aws_s3_bucket.this[0].arn) : null
}

data "aws_iam_policy_document" "this" {
  count       = var.module_enabled ? 1 : 0
  source_json = var.policy_override ? replace(var.policy, "%BUCKET%", aws_s3_bucket.this[0].arn) : data.aws_iam_policy_document.custom_policy[0].json
}

resource "aws_s3_bucket_policy" "this" {
  count  = var.module_enabled ? 1 : 0
  bucket = aws_s3_bucket.this[0].id
  policy = data.aws_iam_policy_document.this[0].json
}
