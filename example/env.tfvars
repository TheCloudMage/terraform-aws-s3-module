# S3 Bucket Module Variables #
##############################
bucket_name        = "terraform-module-demo-test-bucket"
bucket_region      = "us-east-1"
bucket_prefix      = ["production", "account_prefix"]
bucket_suffix      = ["region_suffix"]
bucket_versioning  = true
bucket_mfa         = false
bucket_encryption  = true
bucket_cmk_arn     = "arn:aws:kms:us-east-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
bucket_acl         = "private"
