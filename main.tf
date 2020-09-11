# Terraform Documentation https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
######################
# Data Sources:      #
######################
data "aws_caller_identity" "current" {}

######################
# S3 Bucket:           #
######################
resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name
  acl    = var.acl

  // Bucket Versioning
  versioning {
    enabled    = var.versioning
    mfa_delete = var.mfa_delete
  }

  // Bucket Logging
  dynamic "logging" {
    for_each = local.log_bucket_name != null ? toset(["${local.log_bucket_name}"]) : toset([])
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
    for_each = length(keys(var.cors_rule)) == 0 && var.static_hosting ? toset([]) : toset([var.cors_rule])
    content {
      allowed_headers = coalesce(cors_rule.value.allowed_headers, [])
      allowed_methods = coalesce(cors_rule.value.allowed_methods, [])
      allowed_origins = coalesce(cors_rule.value.allowed_origins, [])
      expose_headers  = coalesce(cors_rule.value.expose_headers, [])
      max_age_seconds = coalesce(cors_rule.value.max_age_seconds[0], 3000)
    }
  }

  // Set the Name tag, and add Created_By, Creation_Date, and Creator_ARN tags with ignore change lifecycle policy.
  // Allow Updated_On to update on each exectuion.
  tags = merge(
    var.tags,
    {
      Name          = local.bucket_name,
      Created_By    = data.aws_caller_identity.current.user_id
      Creator_ARN   = data.aws_caller_identity.current.arn
      Creation_Date = timestamp()
      Updated_On    = timestamp()
      Encrypted     = format("%s", var.encryption)
    }
  )

  lifecycle {
    ignore_changes = [tags["Created_By"], tags["Creation_Date"], tags["Creator_ARN"]]
  }

  // TODO:
  # LifeCycle Policies
  # Replication Configuration
}
