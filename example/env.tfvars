###########################################################################
# Terraform Config Vars:                                                  #
###########################################################################


###########################################################################
# Required S3 Bucket Module Vars:                                         #
#-------------------------------------------------------------------------#
# The following variables require consumer defined values to be provided. #
###########################################################################
s3_bucket_name            = "Value Required"


###########################################################################
# Optional S3 Bucket Module Vars:                                         #
#-------------------------------------------------------------------------#
# The following variables have default values already set by the module.  #
# They will not need to be included in a project root module variables.tf #
# file unless a non-default value needs be assigned to the variable.      #
###########################################################################
s3_bucket_region         = "empty"
s3_bucket_prefix_list    = []
s3_bucket_suffix_list    = []
s3_versioning_enabled    = false
s3_mfa_delete            = false
s3_encryption_enabled    = false
s3_kms_key_arn           = "AES256"
s3_bucket_acl            = "private"
s3_shared_principal_list = []

s3_bucket_tags        = {
    Provisioned_By    = "Terraform"
    Module_GitHub_URL = "https://github.com/CloudMage-TF/AWS-S3Bucket-Module.git"
}