// Default Bucket Test
module "defaults" {
  source = "../"

  bucket = var.bucket

  tags = {
    Provisioned_By    = "Terraform"
    Module_GitHub_URL = "https://github.com/TheCloudMage/terraform-aws-s3-module.git"
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
