######################
# S3 Bucket Outputs: #
######################
output "id" {
  description = "The globally unique identifier for the provisioned S3 bucket."
  value       = aws_s3_bucket.this.id
}

output "arn" {
  description = "The Amazon Resource Name (ARN) of the provisioned S3 bucket. Will be of format arn:aws:s3:::bucketname"
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "The bucket domain name. Will be of format bucketname.s3.amazonaws.com"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The bucket region-specific domain name."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "region" {
  description = "The AWS region the provisioned S3 bucket resides in"
  value       = aws_s3_bucket.this.region
}

output "website_endpoint" {
  description = "The static S3 website endpoint, if static_hosting was enabled. If not, this will be an empty string."
  value       = var.static_hosting ? aws_s3_bucket.this.website_endpoint : null
}

output "website_domain" {
  description = "The domain of the static S3 website endpoint, if static_hosting was enabled. If not, this will be an empty string. This is used to create Route 53 alias records."
  value       = var.static_hosting ? aws_s3_bucket.this.website_domain : null
}

output "hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for this bucket's region."
  value       = var.static_hosting ? aws_s3_bucket.this.hosted_zone_id : null
}
