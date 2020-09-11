// Bucket Policy Tests
# Read Only
module "read_policy" {
  source = "../"

  bucket        = var.bucket
  bucket_suffix = ["region_suffix", "read_only"]
  read_access   = ["arn:aws:iam::123456789101:role/AWS-S3-ReadOnly-Role"]
}

# Write Only
module "write_policy" {
  source = "../"

  bucket        = var.bucket
  region        = "us-west-2"
  bucket_suffix = ["region_suffix", "write"]
  write_access  = ["arn:aws:iam::123456789101:role/AWS-S3-Write-Role"]
}

# Custom Policy
module "custom_policy" {
  source = "../"

  bucket        = var.bucket
  region        = "us-west-2"
  bucket_prefix = ["account_prefix", "custom"]
  custom_policy = data.aws_iam_policy_document.test_policy.json
}

# Write/Custom
module "write_custom_policy" {
  source = "../"

  bucket        = var.bucket
  region        = "us-west-2"
  bucket_prefix = ["account_prefix", "custom"]
  bucket_suffix = ["region_suffix", "write"]
  write_access  = ["arn:aws:iam::123456789101:role/AWS-S3-Write-Role"]
  custom_policy = data.aws_iam_policy_document.test_policy.json
}

# Combined
module "combined_policy" {
  source = "../"

  bucket        = var.bucket
  region        = "us-west-2"
  bucket_prefix = ["account_prefix", "custom"]
  bucket_suffix = ["region_suffix", "combined"]
  read_access   = ["arn:aws:iam::123456789101:role/AWS-S3-ReadOnly-Role"]
  write_access  = ["arn:aws:iam::123456789101:role/AWS-S3-Write-Role"]
  custom_policy = data.aws_iam_policy_document.test_policy.json
}

# Custom Only
module "standalone_custom_policy" {
  source = "../"

  bucket            = var.bucket
  region            = "us-west-2"
  bucket_prefix     = ["account_prefix", "custom"]
  write_access      = ["arn:aws:iam::123456789101:role/AWS-S3-Write-Role"]
  custom_policy     = data.aws_iam_policy_document.test_policy.json
  disable_rw_policy = true
}
