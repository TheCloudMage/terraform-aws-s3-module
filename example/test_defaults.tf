// Default Bucket Test
module "defaults" {
  source = "../"

  bucket = var.bucket

  tags = {
    Provisioned_By    = "Terraform"
    Module_GitHub_URL = "https://github.com/TheCloudMage/TF-AWS-S3-Module.git"
    Testing           = "True"
  }
}

// Region/ACL
module "region_acl" {
  source = "../"

  bucket = var.bucket
  region = "us-east-1"
  acl    = "public-read"
}
