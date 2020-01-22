######################
# S3 Bucket Outputs: #
######################
output "s3_bucket_id" {
  value = var.s3_encryption_enabled == true ? aws_s3_bucket.encrypted_bucket[0].id : aws_s3_bucket.un_encrypted_bucket[0].id
}

output "s3_bucket_arn" {
  value = var.s3_encryption_enabled == true ? aws_s3_bucket.encrypted_bucket[0].arn : aws_s3_bucket.un_encrypted_bucket[0].arn
}

output "s3_bucket_domain_name" {
  value = var.s3_encryption_enabled == true ? aws_s3_bucket.encrypted_bucket[0].bucket_domain_name : aws_s3_bucket.un_encrypted_bucket[0].bucket_domain_name
}

output "s3_bucket_region" {
  value = var.s3_encryption_enabled == true ? aws_s3_bucket.encrypted_bucket[0].region : aws_s3_bucket.un_encrypted_bucket[0].region
}
