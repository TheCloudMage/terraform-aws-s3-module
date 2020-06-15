######################
# S3 Bucket Outputs: #
######################
output "id" {
  description = "The globally unique identifier for the provisioned S3 bucket."
  value = var.module_enabled ? aws_s3_bucket.this[0].id : null
}

output "arn" {
  description = "The Amazon Resource Name (ARN) of the provisioned S3 bucket. Will be of format arn:aws:s3:::bucketname"
  value = var.module_enabled ? aws_s3_bucket.this[0].arn : null
}

output "bucket_domain_name" {
  description = "The bucket domain name. Will be of format bucketname.s3.amazonaws.com"
  value = var.module_enabled ? aws_s3_bucket.this[0].bucket_domain_name : null
}

output "bucket_regional_domain_name" {
  description = "The bucket region-specific domain name."
  value = var.module_enabled ? aws_s3_bucket.this[0].bucket_regional_domain_name : null
}

output "region" {
  description = "The AWS region the provisioned S3 bucket resides in"
  value = var.module_enabled ? aws_s3_bucket.this[0].region : null
}

output "website_endpoint" {
  description = "The static S3 website endpoint, if static_hosting was enabled. If not, this will be an empty string."
  value = var.module_enabled && var.static_hosting ? aws_s3_bucket.this[0].website_endpoint : null
}

output "website_domain" {
  description = "The domain of the static S3 website endpoint, if static_hosting was enabled. If not, this will be an empty string. This is used to create Route 53 alias records."
  value = var.module_enabled && var.static_hosting ? aws_s3_bucket.this[0].website_domain : null
}

output "hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for this bucket's region."
  value = var.module_enabled ? aws_s3_bucket.this[0].hosted_zone_id : null
}
