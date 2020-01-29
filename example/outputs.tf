######################
# S3 Bucket Outputs: #
######################
output "bucket_id" {
  value = module.demo_s3bucket.id
}

output "bucket_arn" {
  value = module.demo_s3bucket.arn
}

output "bucket_domain_name" {
  value = module.demo_s3bucket.domain_name
}

output "bucket_region" {
  value = module.demo_s3bucket.region
}