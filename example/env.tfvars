# S3 Bucket Module Variables #
##############################
bucket_name        = "myBucket"
bucket_region      = "us-west-2"
bucket_prefix      = ["dev", "account_prefix"]
bucket_suffix      = ["region_suffix", "w00t"]
bucket_versioning  = true
bucket_mfa         = true
bucket_encryption  = true
bucket_cmk_arn     = "arn:aws:kms:us-east-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
bucket_acl         = "bucket-owner-read"
