// Bucket Encryption Test with Default Key
module "default_encryption" {
  source = "../"

  bucket     = var.bucket
  region     = "us-east-1"
  encryption = true
}

// Bucket Encryption Test with CMK
module "cmk_encryption" {
  source = "../"

  bucket            = var.bucket
  encryption        = true
  kms_master_key_id = "arn:aws:kms:us-east-1:123456789101:key/127ab3c4-de5f-6e7d-898c-7ba6b5432abc"
}
