// Bucket Versioning Test
// Default Bucket Test
module "versioning" {
  source = "../"

  bucket     = var.bucket
  versioning = true
  mfa_delete = true
}
