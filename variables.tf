###########################################################################
# Required S3 Bucket Module Vars:                                         #
#-------------------------------------------------------------------------#
# The following variables require consumer defined values to be provided. #
###########################################################################
variable "s3_bucket_name" {
  type        = string
  description = "The base name of the S3 bucket that is being requested. This base name can be made unique by specifing values for either the s3_bucket_prefix_list, the s3_bucket_suffix_list, or both module variables."
}


###########################################################################
# Optional S3 Bucket Module Vars:                                         #
#-------------------------------------------------------------------------#
# The following variables have default values already set by the module.  #
# They will not need to be included in a project root module variables.tf #
# file unless a non-default value needs be assigned to the variable.      #
###########################################################################
variable "s3_bucket_region" {
  type        = string
  description = "The AWS region where the S3 bucket will be provisioned."
  default     = "empty"
}

variable "s3_bucket_prefix_list" {
  type        = list
  description = "A prefix list that will be added to the start of the bucket name. For example if s3_bucket_prefix_list=['test'], then the bucket will be named 'test-$${s3_bucket_name}'. This module will also look for the keywords 'region_prefix' and 'account_prefix' and will substitue the current region, or account_id within the module as in the example: s3_bucket_prefix_list=['test', 'region_prefix', 'account_prefix'], resulting in the bucket 'test-us-east-1-1234567890101-$${s3_bucket_name}'. If left blank no prefix will be added."
  default     = []
}

variable "s3_bucket_suffix_list" {
  type        = list
  description = "A suffix list that will be added to the end of the bucket name. For example if s3_bucket_suffix_list=['test'], then the bucket will be named '$${s3_bucket_name}-test'. This module will also look for the keywords 'region_suffix' and 'account_suffix' and will substitue the current region, or account_id within the module as in the example: s3_bucket_suffix_list=['region_suffix', 'account_suffix', 'test'], resulting in the bucket name '$${s3_bucket_name}-us-east-1-1234567890101-test'. If left blank no suffix will be added."
  default     = []
}

variable "s3_versioning_enabled" {
  type        = bool
  description = "Flag to enable bucket object versioning."
  default     = false
}

variable "s3_mfa_delete" {
  type        = bool
  description = "Flag to enable the requirement of MFA in order to delete a bucket, object, or disable object versioning."
  default     = false
}

variable "s3_encryption_enabled" {
  type        = bool
  description = "Flag to enable bucket object encryption."
  default     = false
}

variable "s3_kms_key_arn" {
  type        = string
  description = "The key that will be used to encrypt objects within the new bucket. If the default value of AES256 is unchanged, S3 will encrypt objects with the default KMS key. If a KMS CMK ARN is provided, then S3 will encrypt objects with the specified KMS key instead."
  default     = "AES256"
}

variable "s3_bucket_acl" {
  type        = string
  description = "The Access Control List that will be placed on the bucket. Acceptable Values are: 'private', 'public-read', 'public-read-write', 'aws-exec-read', 'authenticated-read', 'bucket-owner-read', 'bucket-owner-full-control', or 'log-delivery-write'"
  default     = "private"
}

variable "s3_bucket_tags" {
  type        = map
  description = "Specify any tags that should be added to the S3 bucket being provisioned."
  default     = {
    Provisoned_By  = "Terraform"
    GitHub_URL     = "https://github.com/CloudMage-TF/AWS-S3Bucket-Module.git"
  }
}
