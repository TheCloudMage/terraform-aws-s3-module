###########################################################################
# Terraform Config Vars:                                                  #
###########################################################################
variable "provider_region" {
  type        = string
  description = "AWS region to use when making calls to the AWS provider."
  default     = "us-east-1"
}


###########################################################################
# Required S3 Bucket Module Vars:                                         #
#-------------------------------------------------------------------------#
# The following variables require consumer defined values to be provided. #
###########################################################################
variable "bucket" {
  type        = string
  description = "The base name of the S3 bucket that is being requested. This base name can be made unique by specifing values for either the bucket_prefix, the bucket_suffix, or both module variables."
}

###########################################################################
# Optional S3 Bucket Module Vars:                                         #
#-------------------------------------------------------------------------#
# The following variables have default values already set by the module.  #
# They will not need to be included in a project root module variables.tf #
# file unless a non-default value needs be assigned to the variable.      #
###########################################################################
variable "region" {
  type        = string
  description = "The AWS region where the S3 bucket will be provisioned."
  default     = "us-east-1"
}

variable "bucket_prefix" {
  type        = list
  description = "A prefix list that will be added to the start of the bucket name. For example if bucket_prefix=['test'], then the bucket will be named 'test-$${bucket}'. This module will also look for the keywords 'region_prefix' and 'account_prefix' and will substitute the current region, or account_id within the module as in the example: bucket_prefix=['test', 'region_prefix', 'account_prefix'], resulting in the bucket 'test-us-east-1-1234567890101-$${bucket}'. If left blank no prefix will be added."
  default     = []
}

variable "bucket_suffix" {
  type        = list
  description = "A suffix list that will be added to the end of the bucket name. For example if bucket_suffix=['test'], then the bucket will be named '$${bucket}-test'. This module will also look for the keywords 'region_suffix' and 'account_suffix' and will substitute the current region, or account_id within the module as in the example: bucket_suffix=['region_suffix', 'account_suffix', 'test'], resulting in the bucket name '$${bucket}-us-east-1-1234567890101-test'. If left blank no suffix will be added."
  default     = []
}

// Enable Versioning Options
variable "versioning" {
  type        = bool
  description = "Flag to enable bucket object versioning."
  default     = false
}

variable "mfa_delete" {
  type        = bool
  description = "Flag to enable the requirement of MFA in order to delete a bucket, object, or disable object versioning."
  default     = false
}

// Enable Encryption Options
variable "encryption" {
  type        = bool
  description = "Flag to enable bucket object encryption."
  default     = false
}

variable "kms_master_key_id" {
  type        = string
  description = "The key that will be used to encrypt objects within the new bucket. If the default value of AES256 is unchanged, S3 will encrypt objects with the default KMS key. If a KMS CMK ARN is provided, then S3 will encrypt objects with the specified KMS key instead."
  default     = "AES256"
}

variable "acl" {
  type        = string
  description = "The Access Control List that will be placed on the bucket. Acceptable Values are: 'private', 'public-read', 'public-read-write', 'aws-exec-read', 'authenticated-read', 'bucket-owner-read', 'bucket-owner-full-control', or 'log-delivery-write'"
  default     = "private"
}

// Enable Bucket Logging
variable "logging_bucket" {
  type        = string
  description = "The base name of the S3 bucket that will be used as the log bucket for the provisioned s3 buckets access logs"
  default     = null
}

// Enable Static Hosting Options
variable "static_hosting" {
  type        = bool
  description = "Flag that can be set to turn on static hosting within a bucket."
  default     = false
}

variable "index_document" {
  type        = string
  description = "Value of the index file served by the static hosting bucket server if static hosting is enabled."
  default     = "index.html"
}

variable "error_document" {
  type        = string
  description = "Value of the error file served by the static hosting bucket server if static hosting is enabled."
  default     = "error.html"
}

# routing_rules = <<EOF
# [{
#     "Condition": {
#         "KeyPrefixEquals": "docs/"
#     },
#     "Redirect": {
#         "ReplaceKeyPrefixWith": "documents/"
#     }
# }]
# EOF

variable "cors_rule" {
  type        = map
  description = "Cross Origin Resource Sharing ruleset to apply to the bucket"
  default = {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = [3000]
  }
}

variable "tags" {
  type        = map
  description = "Specify any tags that should be added to the S3 bucket being provisioned."
  default = {
    Provisioned_By    = "Terraform"
    Module_GitHub_URL = "https://github.com/CloudMage-TF/AWS-S3Bucket-Module.git"
  }
}

// Customize Bucket Policy
variable "read_access" {
  type        = list(string)
  description = "List of users/roles that will be granted permissions to LIST, DESCRIBE, and GET objects from the provisioned S3 bucket."
  default     = []
}

variable "write_access" {
  type        = list(string)
  description = "List of users/roles that will be granted permissions to PUT, and DELETE objects to/from the provisioned S3 bucket."
  default     = []
}

variable "policy" {
  type        = string
  description = "A policy (data iam_policy_document) to merge with the bucket policy. Use %BUCKET% for bucket name."
  default     = null
}

variable "policy_override" {
  type        = string
  description = "Flag to use the custom provided policy (data iam_policy_document) only, without appending to the default policy. Policy passed is policy applied."
  default     = null
}

// Disable Module
variable "module_enabled" {
  type        = bool
  description = "Module variable that can be used to disable the module from deploying any resources if called from a multi-account/environment root project. Defaults to true, value of false will effectively turn the module off."
  default     = true
}
