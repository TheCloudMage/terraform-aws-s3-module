// Bucket Policy Tests
# Read Only => Expect to apply transport and read only policy statements
module "read_policy" {
  source = "../"

  bucket        = var.bucket
  bucket_suffix = ["region_suffix", "read_only"]
  read_access   = ["arn:aws:iam::123456789101:role/AWS-S3-ReadOnly-Role"]
}

# Write Only => Expect to apply transport and write policy statements
module "write_policy" {
  source = "../"

  bucket        = var.bucket
  region        = "us-west-2"
  bucket_suffix = ["region_suffix", "write"]
  write_access  = ["arn:aws:iam::123456789101:role/AWS-S3-Write-Role"]
}

# Custom Policy => Expect to apply transport and custom policy statements
module "custom_policy" {
  source = "../"

  bucket        = var.bucket
  region        = "us-west-2"
  bucket_prefix = ["account_prefix", "custom"]
  custom_policy = data.aws_iam_policy_document.test_policy.json
}

# Write/Custom => Expect to apply transport, write and custom policy statements
module "write_custom_policy" {
  source = "../"

  bucket        = var.bucket
  region        = "us-west-2"
  bucket_prefix = ["account_prefix", "custom"]
  bucket_suffix = ["region_suffix", "write"]
  write_access  = ["arn:aws:iam::123456789101:role/AWS-S3-Write-Role"]
  custom_policy = data.aws_iam_policy_document.test_policy.json
}

# Public/Custom => Expect to apply transport, public-read, and custom policy statements
module "public_custom_policy" {
  source = "../"

  bucket        = var.bucket
  region        = "us-west-2"
  bucket_prefix = ["account_prefix", "custom"]
  bucket_suffix = ["region_suffix", "write"]
  public_access = true
  custom_policy = data.aws_iam_policy_document.test_policy.json
}

# Combined => Expect to apply transport, read onl, write, and custom policy statements
module "combined_policy" {
  source = "../"

  bucket        = var.bucket
  region        = "us-west-2"
  bucket_prefix = ["account_prefix", "custom"]
  bucket_suffix = ["region_suffix", "combined"]
  read_access   = ["arn:aws:iam::123456789101:role/AWS-S3-ReadOnly-Role"]
  write_access  = ["arn:aws:iam::123456789101:role/AWS-S3-Write-Role"]
  public_access = true
  custom_policy = data.aws_iam_policy_document.test_policy.json
}

# Custom Only => Expect to apply only custom policy statement
module "standalone_custom_policy" {
  source = "../"

  bucket                 = var.bucket
  region                 = "us-west-2"
  bucket_prefix          = ["account_prefix", "custom"]
  write_access           = ["arn:aws:iam::123456789101:role/AWS-S3-Write-Role"]
  custom_policy          = data.aws_iam_policy_document.test_policy.json
  disable_policy_autogen = true
}
