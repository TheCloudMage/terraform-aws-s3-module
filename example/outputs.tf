######################
# S3 Bucket Outputs: #
######################
output "id" {
  value = module.defaults.id
}

output "arn" {
  value = module.defaults.arn
}

output "bucket_domain_name" {
  value = module.defaults.domain_name
}

output "bucket_regional_domain_name" {
  value = module.defaults.bucket_regional_domain_name
}

output "region" {
  value = module.defaults.region
}

output "website_endpoint" {
  value = module.defaults.website_endpoint
}

output "website_domain" {
  value = module.defaults.website_domain
}

output "hosted_zone_id" {
  value = module.defaults.hosted_zone_id
}
