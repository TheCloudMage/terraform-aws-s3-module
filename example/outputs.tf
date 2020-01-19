######################
# S3 Bucket:         #
######################
output "bucket_id" {
  value = module.demo_s3bucket.s3_bucket_id
}

output "bucket_arn" {
  value = module.demo_s3bucket.s3_bucket_arn
}

output "bucket_domain_name" {
  value = module.demo_s3bucket.s3_bucket_domain_name
}

output "bucket_region" {
  value = module.demo_s3bucket.s3_bucket_region
}