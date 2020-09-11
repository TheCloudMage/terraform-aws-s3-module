// Bucket Naming Tests
module "naming" {
  source = "../"

  bucket        = var.bucket
  region        = "us-west-2"
  bucket_prefix = ["account_prefix", "yes"]
  bucket_suffix = ["region_suffix", "42"]
}
