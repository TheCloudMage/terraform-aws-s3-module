// Bucket Static Hosting
module "hosting" {
  source = "../"

  bucket         = var.bucket
  static_hosting = true
  index_document = "index.py"
  error_document = "error.py"

  cors_rule = {
    allowed_headers = ["*"]
    allowed_methods = ["POST"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = [1500]
  }
}