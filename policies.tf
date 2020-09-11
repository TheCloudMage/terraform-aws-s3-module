#######################
# S3 Bucket Policies: #
#######################
// Construct the S3 Bucket Policy to deny the unencrypted transport of objects
data "aws_iam_policy_document" "encryption_in_transit" {
  statement {
    sid = "DenyNonSecureTransport"
    effect = "Deny"

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
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false"
      ]
    }
  }
}

// S3 Read Only Access Policy
data "aws_iam_policy_document" "read_access" {
  statement {
    sid    = "ReadAccess"
    effect = "Allow"

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
      identifiers = length(var.read_access) > 0 ? var.read_access : ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

// S3 Write Access Policy
data "aws_iam_policy_document" "write_access" {
  statement {
    sid    = "WriteAccess"
    effect = "Allow"

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
      identifiers = length(var.write_access) > 0 ? var.write_access : ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

// Use policy overrides to evalute a new policy to pass to the next layer.
// This is essentially a dynamic conditional merge of the encryption_in_transit, read, write, and custom policies.
data "aws_iam_policy_document" "read_policy" {
  source_json   = data.aws_iam_policy_document.encryption_in_transit.json
  override_json = length(var.read_access) > 0 ? data.aws_iam_policy_document.read_access.json : null
}

data "aws_iam_policy_document" "write_policy" {
  source_json   = data.aws_iam_policy_document.read_policy.json
  override_json = length(var.write_access) > 0 ? data.aws_iam_policy_document.write_access.json : null
}

data "aws_iam_policy_document" "this" {
  # source_json   = var.custom_policy != "null" ? replace(var.custom_policy, "%BUCKET%", aws_s3_bucket.this.arn) : data.aws_iam_policy_document.write_policy.json
  source_json = data.aws_iam_policy_document.write_policy.json
  override_json = local.custom_policy != null ? local.custom_policy : null
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = var.disable_policy_autogen && local.custom_policy != null ? local.custom_policy : data.aws_iam_policy_document.this.json
}
