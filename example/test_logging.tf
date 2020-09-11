// Bucket Logging
module "logging" {
  source = "../"

  bucket         = var.bucket
  logging_bucket = "test-logging-bucket-configuration-test"
}