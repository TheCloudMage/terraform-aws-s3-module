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
variable "bucket_name" {
  type        = string
  description = "The name specified for the provisioned bucket."
}


###########################################################################
# Optional S3 Bucket Module Vars:                                         #
#-------------------------------------------------------------------------#
# The following variables have default values already set by the module.  #
# They will not need to be included in a project root module variables.tf #
# file unless a non-default value needs be assigned to the variable.      #
###########################################################################
variable "bucket_region" {
  type        = string
  description = "The AWS region where the S3 bucket will be provisioned."
  default     = "empty"
}

variable "bucket_prefix" {
  type        = list
  description = "A prefix list that will be added to the beginning of the bucket name."
  // This module will also look for the keywords 'region_prefix' and 'account_prefix'
  default     = []
}

variable "bucket_suffix" {
  type        = list
  description = "A suffix list that will be added to the end of the bucket name."
  // This module will look for the keywords 'region_suffix' and 'account_suffix'
  default     = []
}

variable "bucket_versioning" {
  type        = bool
  description = "Flag to enable bucket object versioning."
  default     = false
}

variable "bucket_mfa" {
  type        = bool
  description = "Flag to enable the requirement of MFA in order to delete a bucket, object, or disable object versioning."
  default     = false
}

variable "bucket_encryption" {
  type        = bool
  description = "Flag to enable bucket object encryption."
  default     = false
}

variable "bucket_cmk_arn" {
  type        = string
  description = "The key that will be used to encrypt objects within the new bucket. If the default value of AES256 is unchanged, S3 will encrypt objects with the default KMS key. If a KMS CMK ARN is provided, then S3 will encrypt objects with the specified KMS key instead."
  default     = "AES256"
}

variable "bucket_acl" {
  type        = string
  description = "The Access Control List that will be placed on the bucket. Acceptable Values are: 'private', 'public-read', 'public-read-write', 'aws-exec-read', 'authenticated-read', 'bucket-owner-read', 'bucket-owner-full-control', or 'log-delivery-write'"
  default     = "private"
}

variable "bucket_tags" {
  type        = map
  description = "Specify any tags that should be added to the S3 bucket being provisioned."
  default     = {
    Provisioned_By    = "Terraform"
    Module_GitHub_URL = "https://github.com/CloudMage-TF/AWS-S3Bucket-Module.git"
  }
}