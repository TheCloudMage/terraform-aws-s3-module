######################
# S3 Bucket:         #
######################
output "s3_bucket_id" {
  value = "${var.s3_encryption_enabled == true ? aws_s3_bucket.encrypted_bucket.*.id : aws_s3_bucket.un_encrypted_bucket.*.id}"
}

output "s3_bucket_arn" {
  value = "${var.s3_encryption_enabled == true ? aws_s3_bucket.encrypted_bucket.*.arn : aws_s3_bucket.un_encrypted_bucket.*.arn}"
}

output "s3_bucket_domain_name" {
  value = "${var.s3_encryption_enabled == true ? aws_s3_bucket.encrypted_bucket.*.bucket_domain_name : aws_s3_bucket.un_encrypted_bucket.*.bucket_domain_name}"
}

output "s3_bucket_region" {
  value = "${var.s3_encryption_enabled == true ? aws_s3_bucket.encrypted_bucket.*.region : aws_s3_bucket.un_encrypted_bucket.*.region}"
}
