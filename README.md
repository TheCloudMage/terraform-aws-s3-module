# Terrafrom S3 Bucket Module

## Description

This AWS S3 bucket module is designed to produce a secure/in-secure AWS S3 bucket depending on the options passed to the module. This module was created with dynamic options that allow the consumer of the module to determine project by project what S3 bucket options should be enforced on the requested bucket at the time of the bucket provisioning provisioning. It has options that allow the provisioned bucket to be fully insecure, or conversely fully encrypted with an enforcing bucket policy ensuring objects within the bucket are both PUT and stored using either the S3 default encryption key, or an AWS KMS (Key Management Service) CMK (Customer Managed Key)

<br>

<!-- ![Hero](images/tf_kms.png) -->

<br>

## Pre-Requisite Templates

None Defined for un-encrypted bucket. If the requested bucket requires encryption using a CMK, then the CMK will have to have already been provisioned via the direct TF root project or by using a KMS CMK module.

<br>

## Variables

The following variables are utilized by this module and cause the module to behave dynamically based upon the variables that are populated and passed into the module.

<br>

### s3_bucket_region

`OPTIONAL`: This variable can contain a specific AWS region where the requested S3 bucket should be provisioned. If no region is specified, the bucket will be created in the region, from which the module is running against via the terraform root module. The string value of the region is set to **empty**, this allows the module to replace the empty string with the currently executed AWS region data source constructed in the module.

<br>

```terraform
variable "s3_bucket_region" {
  type        = string
  description = "The AWS region where the S3 bucket will be provisioned."
  default     = "empty"
}
```

<br>

`EXAMPLE`: Include the following in your tfvars file

```terraform
s3_bucket_region = "us-west-2"
```

<br><br>

### s3_bucket_name

`REQUIRED`: This variable should be passed containing the base name of the bucket that is being requested.

<br>

```terraform
variable "s3_bucket_name" {
  type        = string
  description = "The base name of the S3 bucket that is being requested. This base name can be made unique by specifing values for either the s3_bucket_prefix_list, the s3_bucket_suffix_list, or both module variables."
}
```

<br>

> Note: If values are supplied for either the `s3_bucket_prefix_list`, `s3_bucket_suffix_list` or both, then the specified values will be added to the s3_bucket_name. See the variable section pertaining to those lists for additional information on how they can be used to change the requested S3 bucket name.

> BucketName: The bucket name must be all lowercase, with only numbers, lowercase characters or a hyphan. The Bucket name must also be globally unique which is where the prefix or suffix variable helpers come in to help uniquely the desired bucket name.

> BucketName Case: In the event that an upper case name is provided for the bucket name variable, the module will run a lower() function on the final bucket name before assigning the bucket name to the bucket api call to ensure that all passed bucket names are lowercase.

<br>

`EXAMPLE`: Include the following in your tfvars file

```terraform
s3_bucket_name = "myawesomebucket"
```

<br><br>

### s3_bucket_prefix_list

`OPTIONAL`: This list variable should contain the values of any prefix that you want to prepend to beginning of the requested S3 bucket. Specifying any sequence of values to the list will change the calculated bucket name by adding each of the specified values with a hyphan to the begging of the supplied s3_bucket_name.

<br>

__Note: Special s3_bucket_prefix_list Keywords:__

* `region_prefix`: Adding this keyword to the bucket prefix list will result in the resolution of the desired or current execution region, and will place that region into the bucket name string.

* `account_prefix`: Adding this keyword to the bucket prefix list will result in the resolution of the current execution region, and will place that account Id into the bucket name string.

<br>

```terraform
variable "s3_bucket_prefix_list" {
  type        = list
  description = "A prefix list that will be added to the start of the bucket name. For example if s3_bucket_prefix_list=['test'], then the bucket will be named 'test-$${s3_bucket_name}'. This module will also look for the keywords 'region_prefix' and 'account_prefix' and will substitute the current region, or account_id within the module as in the example: s3_bucket_prefix_list=['test', 'region_prefix', 'account_prefix'], resulting in the bucket 'test-us-east-1-1234567890101-$${s3_bucket_name}'. If left blank no prefix will be added."
  default     = []
}
```

<br>

`EXAMPLE`: Include the following in your tfvars file

```terraform
s3_bucket_prefix_list = ["rds", "region_prefix"]
```

<br>

`terraform plan -var='s3_bucket_name="myBucket"'`

```terraform
Terraform will perform the following actions:

  # aws_s3_bucket.not_encrypted_bucket[0] will be created
  + resource "aws_s3_bucket" "not_encrypted_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "mybucket"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = "us-east-1"
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = false
          + mfa_delete = false
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

> Note: how the command passed in an upper case character in *myBucket*, and it was auto converted to a lower case character.

<br>

Now lets pass in a prefix or 2

`terraform plan -var='s3_bucket_name="myBucket"' -var s3_bucket_prefix_list='["rds", "region_prefix"]'`

```terraform
Terraform will perform the following actions:

  # aws_s3_bucket.not_encrypted_bucket[0] will be created
  + resource "aws_s3_bucket" "not_encrypted_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "rds-us-east-1-mybucket"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = "us-east-1"
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = false
          + mfa_delete = false
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

<br><br>

### s3_bucket_suffix_list

`OPTIONAL`: This list variable should contain the values of any suffix that you want to append to end of the requested S3 bucket. Specifying any sequence of values to the list will change the calculated bucket name by adding each of the specified values with a hyphan to the end of the supplied s3_bucket_name.

<br>

__Note: Special s3_bucket_suffix_list Keywords:__

* `region_suffix`: Adding this keyword to the bucket prefix list will result in the resolution of the desired or current execution region, and will place that region into the bucket name string.

* `account_suffix`: Adding this keyword to the bucket prefix list will result in the resolution of the current execution region, and will place that account Id into the bucket name string.

<br>

```terraform
variable "s3_bucket_suffix_list" {
  type        = list
  description = "A suffix list that will be added to the end of the bucket name. For example if s3_bucket_suffix_list=['test'], then the bucket will be named '$${s3_bucket_name}-test'. This module will also look for the keywords 'region_suffix' and 'account_suffix' and will substitute the current region, or account_id within the module as in the example: s3_bucket_suffix_list=['region_suffix', 'account_suffix', 'test'], resulting in the bucket name '$${s3_bucket_name}-us-east-1-1234567890101-test'. If left blank no suffix will be added."
  default     = []
}
```

<br>

`EXAMPLE`: Include the following in your tfvars file

```terraform
s3_bucket_suffix_list = ["account_suffix", "w00t"]
```

<br>

`terraform plan -var='s3_bucket_name="mybucket"'`

```terraform
Terraform will perform the following actions:

  # aws_s3_bucket.not_encrypted_bucket[0] will be created
  + resource "aws_s3_bucket" "not_encrypted_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "mybucket"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = "us-east-1"
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = false
          + mfa_delete = false
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

<br>

Now lets pass in a suffix or 2

`terraform plan -var='s3_bucket_name="mybucket"' -var s3_bucket_suffix_list='["account_suffix", "w00t"]'`

```terraform
Terraform will perform the following actions:

  # aws_s3_bucket.not_encrypted_bucket[0] will be created
  + resource "aws_s3_bucket" "not_encrypted_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "mybucket-123456789101-w00t"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = "us-east-1"
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = false
          + mfa_delete = false
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

> Note: You can use any combination of prefix and suffix values together in order to create a unique account specific bucket path.

<br>

`terraform plan -var='s3_bucket_name="mybucket"' -var s3_bucket_prefix_list='["prod", "account_prefix"] -var s3_bucket_suffix_list='["region_suffix"]'`

```terraform
Terraform will perform the following actions:

  # aws_s3_bucket.not_encrypted_bucket[0] will be created
  + resource "aws_s3_bucket" "not_encrypted_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "prod-123456789101-mybucket-us-east-1"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = "us-east-1"
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = false
          + mfa_delete = false
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

<br><br>

### s3_versioning_enabled

`OPTIONAL`: This variable will turn flag versioning on or off on the bucket. It is important to note that once Versioning is turned on within S3 for a given bucket, it can be later disabled, but never removed.

<br>

```terraform
variable "s3_versioning_enabled" {
  type        = bool
  description = "Flag to enable bucket object versioning."
  default     = false
}
```

<br>

`EXAMPLE`: Include the following in your tfvars file

```terraform
s3_versioning_enabled = true
```

<br><br>

### s3_mfa_delete

`OPTIONAL`: This variable will turn flag the requirement for MFA authentication prior to removing an object version, or suspending versioning within a bucket that has versioning enabled.

<br>

```terraform
variable "s3_mfa_delete" {
  type        = bool
  description = "Flag to enable the requirement of MFA in order to delete an object version, or disable object versioning once versioning has been enabled."
  default     = false
}
```

<br>

`EXAMPLE`: Include the following in your tfvars file

```terraform
s3_mfa_delete = true
```

<br><br>

### s3_bucket_acl

`OPTIONAL`: This variable is used to pass the desired permissions of the bucket at the time of provisioning the bucket. The default value is set to private but can be changed by providing a valid permission keyword in the s3_bucket_acl variable.

<br>

```terraform
variable "s3_bucket_acl" {
  type        = string
  description = "The Access Control List that will be placed on the bucket. Acceptable Values are: 'private', 'public-read', 'public-read-write', 'aws-exec-read', 'authenticated-read', 'bucket-owner-read', 'bucket-owner-full-control', or 'log-delivery-write'"
  default     = "private"
```

<br>

__Valid Permission Values:__

* **private:** Owner gets FULL_CONTROL. No one else has access rights (default).
* **public-read:** Owner gets FULL_CONTROL. The AllUsers group (see Who Is a Grantee?) gets READ access.
* **public-read-write:** Owner gets FULL_CONTROL. The AllUsers group gets READ and WRITE access. Granting this on a bucket is generally not recommended.
* **aws-exec-read:** Owner gets FULL_CONTROL. Amazon EC2 gets READ access to GET an Amazon Machine Image (AMI) bundle from Amazon S3.
* **authenticated-read:** Owner gets FULL_CONTROL. The AuthenticatedUsers group gets READ access.
* **bucket-owner-read:** Object owner gets FULL_CONTROL. Bucket owner gets READ access. If you specify this canned ACL when creating a bucket, Amazon S3 ignores it.
* **bucket-owner-full-control:** Both the object owner and the bucket owner get FULL_CONTROL over the object. If you specify this canned ACL when creating a bucket, Amazon S3 ignores it.
* **log-delivery-write:** The LogDelivery group gets WRITE and READ_ACP permissions on the bucket. For more information about logs, see (Amazon S3 Server Access Logging).

<br>

`EXAMPLE`: Include the following in your tfvars file

```terraform
s3_bucket_acl = "public-read"
```

<br><br>

### s3_encryption_enabled

`OPTIONAL`: This variable is flag if encryption should be configured on the requested bucket. Setting this value to true will automatically turn on encyrption on the bucket at the time of provisioning using the default S3/AES256 AWS managed KMS Key.

<br>

> Note: It will also automatically create a bucket policy that will be attached to the bucket forcing encryption of new object that is PUT into the bucket.

<br>

```terraform
variable "s3_encryption_enabled" {
  type        = bool
  description = "Flag to enable bucket object encryption."
  default     = false
}
```

<br>

`EXAMPLE`: Include the following in your tfvars file

```terraform
s3_encryption_enabled = true
```

<br>

> Note: Setting the `s3_encryption_enabled` option to true will automatically add the following bucket policy to the bucket at the time of provisioning:

<br>

```yaml
Statement:
  - Sid: "DenyNonSecureTransport"
    Effect: Deny
    Principal:
      AWS:
        - "*"
      Action:
        - "s3:*"
      Resources:
        - "arn:aws:s3:::my_bucket"
        - "arn:aws:s3:::my_bucket/*"
      Condition: {
        "Bool": {
          "aws:SecureTransport: "false"
        }
      }
  - Sid: "DenyIncorrectEncryptionHeader"
    Effect: Deny
    Principal:
      AWS:
        - "*"
      Action:
        - "s3:PutObject"
      Resources:
        - "arn:aws:s3:::my_bucket"
        - "arn:aws:s3:::my_bucket/*"
      Condition: {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": ["aws:kms","AES256"]
        }
      }
  - Sid: "DenyUnEncryptedObjectUploads"
    Effect: Deny
    Principal:
      AWS:
        - "*"
      Action:
        - "s3:PutObject"
      Resources:
        - "arn:aws:s3:::my_bucket"
        - "arn:aws:s3:::my_bucket/*"
      Condition: {
        "Null": {
          "s3:x-amz-server-side-encryption": "true"
        }
      }
```

<br>

`terraform plan -var='s3_bucket_name="mybucket"' -var s3_encryption_enabled='true'`

```terraform
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.aws_region.current: Refreshing state...
data.aws_caller_identity.current: Refreshing state...
data.aws_iam_policy_document.this: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.encrypted_bucket[0] will be created
  + resource "aws_s3_bucket" "encrypted_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "mybucket"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + policy                      = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "s3:*"
                      + Condition = {
                          + Bool = {
                              + aws:SecureTransport = "false"
                            }
                        }
                      + Effect    = "Deny"
                      + Principal = {
                          + AWS = "*"
                        }
                      + Resource  = "aws_s3_bucket.encrypted_bucket.arn, aws_s3_bucket.encrypted_bucket.arn/*"
                      + Sid       = "DenyNonSecureTransport"
                    },
                  + {
                      + Action    = "s3:PutObject"
                      + Condition = {
                          + StringNotEquals = {
                              + s3:x-amz-server-side-encryption = [
                                  + "aws:kms",
                                  + "AES256",
                                ]
                            }
                        }
                      + Effect    = "Deny"
                      + Principal = {
                          + AWS = "*"
                        }
                      + Resource  = "aws_s3_bucket.encrypted_bucket.arn, aws_s3_bucket.encrypted_bucket.arn/*"
                      + Sid       = "DenyIncorrectEncryptionHeader"
                    },
                  + {
                      + Action    = "s3:PutObject"
                      + Condition = {
                          + Null = {
                              + s3:x-amz-server-side-encryption = "true"
                            }
                        }
                      + Effect    = "Deny"
                      + Principal = {
                          + AWS = "*"
                        }
                      + Resource  = "aws_s3_bucket.encrypted_bucket.arn, aws_s3_bucket.encrypted_bucket.arn/*"
                      + Sid       = "DenyUnEncryptedObjectUploads"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + region                      = "us-east-1"
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + server_side_encryption_configuration {
          + rule {
              + apply_server_side_encryption_by_default {
                  + sse_algorithm     = "AES256"
                }
            }
        }

      + versioning {
          + enabled    = false
          + mfa_delete = false
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

<br><br>

### s3_kms_key_arn

`OPTIONAL`: This variable is used to define an existing KMS CMK that is preferred to encrypt objects into the bucket. Using a CMK instead of the default AWS Managed KMS key allows more granular control over the permissioning of the encryption key used to encryption the objects within the bucket.

<br>

```terraform
variable "s3_kms_key_arn" {
  type        = string
  description = "The key that will be used to encrypt objects within the new bucket. If the default value of AES256 is unchanged, S3 will encrypt objects with the default KMS key. If a KMS CMK ARN is provided, then S3 will encrypt objects with the specified KMS key instead."
  default     = "AES256"
}
```

<br>

`EXAMPLE`: Include the following in your tfvars file

```terraform
s3_kms_key_arn = "arn:aws:kms:us-east-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
```

<br>

> Note: When supplying a KMS CMK Key ARN, the bucket encryption type will automatically switch from **AES256** to **aws:kms**. Encryption will work the same way, only using the provided key instead of the Amazon managed default S3 key. The bucket policy shown above will also still be applied.

<br>

`terraform plan -var 's3_bucket_name="mybucket"' -var s3_encryption_enabled='true' -var s3_kms_key_arn= 'arn:aws:kms:us-east-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab'`

```terraform
+ server_side_encryption_configuration {
          + rule {
              + apply_server_side_encryption_by_default {
                  + kms_master_key_id = "arn:aws:kms:us-east-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
                  + sse_algorithm     = "aws:kms"
                }
            }
        }
```

<br><br>

## Outputs

The template will finally create the following outputs that can be pulled and used in subsequent terraform runs via data sources. The outputs will be written to the terraform state file.

<br>

```terraform
######################
# S3 Bucket:         #
######################
output "s3_bucket_id" {
  value = "${var.s3_encryption_enabled == true ? aws_s3_bucket.encrypted_bucket.*.id : aws_s3_bucket.not_encrypted_bucket.*.id}"
}

output "s3_bucket_arn" {
  value = "${var.s3_encryption_enabled == true ? aws_s3_bucket.encrypted_bucket.*.arn : aws_s3_bucket.not_encrypted_bucket.*.arn}"
}

output "s3_bucket_domain_name" {
  value = "${var.s3_encryption_enabled == true ? aws_s3_bucket.encrypted_bucket.*.bucket_domain_name : aws_s3_bucket.not_encrypted_bucket.*.bucket_domain_name}"
}

output "s3_bucket_region" {
  value = "${var.s3_encryption_enabled == true ? aws_s3_bucket.encrypted_bucket.*.region : aws_s3_bucket.not_encrypted_bucket.*.region}"
}

```

<br>

## Dependencies

### Required

* [Terraform](https://www.terraform.io/)
* [GIT](https://git-scm.com/download/win)
* [AWS-Account](https://https://aws.amazon.com/)

### Recommended

* [Terraform for VSCode](https://github.com/mauve/vscode-terraform)
* [Terraform Config Inspect](https://github.com/hashicorp/terraform-config-inspect)

<br>

## Contributions and Contacts

This project is owned by [CloudMage](rnason@cloudmage.com).

To contribute, please:

* Fork the project
* Create a local branch
* Submit Changes
* Create A Pull Request
