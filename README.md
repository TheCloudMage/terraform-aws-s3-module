<!-- markdownlint-disable MD024 -->
<!-- markdownlint-disable MD025 -->
<!-- markdownlint-disable MD028 -->

# Terraform S3 Bucket Module

![Hero](images/tf_s3.png)

<br>

# Getting Started

This AWS S3 bucket module is designed to produce a secure/in-secure AWS S3 bucket depending on the options passed to the module. This module was created with dynamic options that allow the consumer of the module to determine, project by project, what S3 bucket options should be enforced on the requested bucket at the time of the bucket provisioning. It has options that allow the provisioned bucket to be fully insecure, or conversely fully encrypted with an enforcing bucket policy ensuring objects within the bucket are both PUT and stored using either the S3 default encryption key or an AWS KMS (Key Management Service) CMK (Customer Managed Key)

<br><br>

# Module Pre-Requisites and Dependencies

None Defined for an un-encrypted bucket. If the requested bucket requires encryption using a CMK, then the CMK will have to have already been provisioned via the direct TF root project or by using a KMS CMK module.

<br><br>

# Module Usage

```terraform
module "s3_bucket" {
  source = "git@github.com:CloudMage-TF/AWS-S3Bucket-Module?ref=v1.1.0"

  // Required Variables
  s3_bucket_name              = "backup-bucket"
  
  // Optional Variables with module defined default values assigned
  # s3_bucket_region          = "empty"
  # s3_bucket_prefix_list     = []
  # s3_bucket_suffix_list     = []
  # s3_versioning_enabled     = false
  # s3_mfa_delete             = false
  # s3_bucket_acl             = "private"
  # s3_encryption_enabled     = false
  # s3_kms_key_arn            = "AES256"
  
  // Tags
  # s3_bucket_tags            = {
  #   Provisoned_By  = "Terraform"
  #   GitHub_URL     = "https://github.com/CloudMage-TF/AWS-S3Bucket-Module.git"
  # }
}
```

<br><br>

# Terraform Variables

Module variables that need to either be defined or re-defined with a non-default value can easily be hardcoded inline directly within the module call block or from within the root project that is consuming the module. If using the second approach then the root project must have it's own custom variables defined within the projects `variables.tf` file with set default values or with the values provided from a separate environmental `terraform.tfvar` file. Examples of both approaches can be found below. Note that for the standards used within this documentation, all variables will mostly use the first approach for ease of readability.

<br>

> __NOTE:__ There is also a third way to provide variable values using Terraform data sources. A data source is a unique type of code block used within a project that either instantiates or collects data that can be referenced throughout the project. A data source, for example,  can be declared to read the terraform state file and gather all of the available information from a previously deployed project stack. Any of the data contained within the data source can then be referenced to set the value of a project or module variable.

<br><br>

## Setting Variables Inline

```terraform
module "s3" {
  source = "git@github.com:CloudMage-TF/AWS-S3Bucket-Module?ref=v1.1.0"

  // Required Variables
  s3_bucket_name        = "somebucketname"
}
```

<br><br>

## Setting Variables in a Terraform Root Project

<br>

### Terraform Root Project/variables.tf

```terraform
variable "bucket_name" {
  type        = string
  description = "Bucket Name"
}
```

<br>

### Terraform Root Project/terraform.tfvars

```terraform
bucket_name = "somebucketname"
```

<br>

### Terraform Root Project/main.tf

```terraform
module "s3" {
  source = "git@github.com:CloudMage-TF/AWS-S3Bucket-Module?ref=v1.1.0"

  // Required Variables
  s3_bucket_name = var.bucket_name
}
```

<br><br>

# Required Variables

The following required module variables do not contain default values and must be set by the consumer of the module to use the module successfully.

<br><br>

## :red_circle: s3_bucket_name

<br>

![Required](images/neon_required.png)

<br>

This variable should be passed containing the base name of the bucket that is being requested.

<br>

> __BucketName:__ The bucket name must be all lowercase, with only numbers, lowercase characters or a hyphen. The Bucket name must also be globally unique which is where the prefix or suffix variable helpers come in to help uniquely the desired bucket name. In the event that an upper case name is provided for the bucket name variable, the module will run a lower() function on the final bucket name before assigning the bucket name to the bucket API call to ensure that all passed bucket names are lowercase.

<br><br>

### Declaration in module variables.tf

```terraform
variable "s3_bucket_name" {
  type        = string
  description = "The base name of the S3 bucket that is being requested. This base name can be made unique by specifing values for either the s3_bucket_prefix_list, the s3_bucket_suffix_list, or both module variables."
}
```

<br>

> __Note:__ If values are supplied for either the `s3_bucket_prefix_list`, `s3_bucket_suffix_list` or `both`, then the specified values will be added to the s3_bucket_name. See the variable section about those lists for additional information on how they can be used to change the requested S3 bucket name.

<br><br>

### Module usage in project root main.tf in project root main.tf

```terraform
module "s3_bucket" {
  source = "git@github.com:CloudMage-TF/AWS-S3Bucket-Module?ref=v1.1.0"

  // Required Variables
  s3_bucket_name              = "myBucket"
}
```

<br><br><br>

## Base Module Execution

Once all of the modules required values have been assigned, then the module can be executed in its base capacity.

<br><br>

### Example `terraform plan` output

```terraform
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

module.demo_s3bucket.data.aws_region.current: Refreshing state...
module.demo_s3bucket.data.aws_caller_identity.current: Refreshing state...
module.demo_s3bucket.data.aws_iam_policy_document.this: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.demo_s3bucket.aws_s3_bucket.un_encrypted_bucket[0] will be created
  + resource "aws_s3_bucket" "un_encrypted_bucket" {
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

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

<br>

> __Note:__ Observe how the command passed in an upper case character in myBucket, and it was auto-converted to lower case characters.

<br><br>

# Optional Variables

The following optional module variables are not required because they already have default values assigned when the variables where defined within the modules `variables.tf` file. If the default values do not need to be changed by the root project consuming the module, then they do not even need to be included in the root project. If any of the variables do need to be changed, then they can be added to the root project in the same way that the required variables were defined and utilized. Optional variables also may alter how the module provisions resources in the cases of encryption or IAM policy generation. A variable could flag an encryption requirement when provisioning an S3 bucket or Dynamo table by providing a KMS CMK, for example. Another use case may be the passage of ARN values to allow users or roles access to services or resources, whereas by default permissions would be more restrictive or only assigned to the account root or a single IAM role. A detailed explanation of each of this modules optional variables can be found below:

<br><br>

## :large_blue_circle: s3_bucket_region

<br>

![Optional](images/neon_optional.png)

<br>

This variable can contain a specific AWS region where the requested S3 bucket should be provisioned. If no region is specified, the bucket will be created in the region, from which the module is running against via the root project. The default string value of the region variable is set to **empty**, this allows the module to replace the empty string with the current AWS region obtained by the Terraform data source provider `aws_region`.

<br><br>

### Declaration in module variables.tf

```terraform
variable "s3_bucket_region" {
  type        = string
  description = "The AWS region where the S3 bucket will be provisioned."
  default     = "empty"
}
```

<br><br>

### Module usage in project root main.tf in project root main.tf

```terraform
module "s3_bucket" {
  source = "git@github.com:CloudMage-TF/AWS-S3Bucket-Module?ref=v1.1.0"

  // Required Variables
  s3_bucket_name              = "myBucket"
  s3_bucket_region            = "us-west-2"
}
```

<br><br>

### Example `terraform plan` output

```terraform
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

module.demo_s3bucket.data.aws_caller_identity.current: Refreshing state...
module.demo_s3bucket.data.aws_region.current: Refreshing state...
module.demo_s3bucket.data.aws_iam_policy_document.this: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.demo_s3bucket.aws_s3_bucket.un_encrypted_bucket[0] will be created
  + resource "aws_s3_bucket" "un_encrypted_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "mybucket"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = "us-west-2"
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

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

<br><br><br>

## :large_blue_circle: s3_bucket_prefix_list

<br>

![Optional](images/neon_optional.png)

<br>

This list variable should contain the values of any prefix that you want to prepend to the beginning of the requested S3 bucket. Specifying any sequence of values to the list will change the calculated bucket name by adding each of the specified values with a hyphen to the begging of the supplied s3_bucket_name.

<br>

__Note: Special s3_bucket_prefix_list Keywords:__

* `region_prefix`: Adding this keyword to the bucket prefix list will result in the resolution of the desired or current execution region, and will place that region into the bucket name string.

* `account_prefix`: Adding this keyword to the bucket prefix list will result in the resolution of the current execution region, and will place that account Id into the bucket name string.

<br><br>

### Declaration in module variables.tf

```terraform
variable "s3_bucket_prefix_list" {
  type        = list
  description = "A prefix list that will be added to the start of the bucket name. For example if s3_bucket_prefix_list=['test'], then the bucket will be named 'test-${s3_bucket_name}'. This module will also look for the keywords 'region_prefix' and 'account_prefix' and will substitute the current region, or account_id within the module as in the example: s3_bucket_prefix_list=['test', 'region_prefix', 'account_prefix'], resulting in the bucket 'test-us-east-1-1234567890101-${s3_bucket_name}'. If left blank no prefix will be added."
  default     = []
}
```

<br><br>

### Module usage in project root main.tf with account_prefix

```terraform
module "s3_bucket" {
  source = "git@github.com:CloudMage-TF/AWS-S3Bucket-Module?ref=v1.1.0"

  // Required Variables
  s3_bucket_name              = "myBucket"
  s3_bucket_region            = "us-east-1"
  s3_bucket_prefix_list       = ["dev", "account_prefix"]
}
```

<br><br>

### Example `terraform plan` output

```terraform
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

module.demo_s3bucket.data.aws_region.current: Refreshing state...
module.demo_s3bucket.data.aws_caller_identity.current: Refreshing state...
module.demo_s3bucket.data.aws_iam_policy_document.this: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.demo_s3bucket.aws_s3_bucket.un_encrypted_bucket[0] will be created
  + resource "aws_s3_bucket" "un_encrypted_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "dev-123456789101-mybucket"
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

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

<br><br>

### Module usage in project root main.tf in project root main.tf with account_prefix

```terraform
module "s3_bucket" {
  source = "git@github.com:CloudMage-TF/AWS-S3Bucket-Module?ref=v1.1.0"

  // Required Variables
  s3_bucket_name              = "myBucket"
  s3_bucket_region            = "us-east-1"
  s3_bucket_prefix_list       = ["dev", "region_prefix"]
}
```

<br><br>

### Example `terraform plan` output

```terraform
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

module.demo_s3bucket.data.aws_region.current: Refreshing state...
module.demo_s3bucket.data.aws_caller_identity.current: Refreshing state...
module.demo_s3bucket.data.aws_iam_policy_document.this: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.demo_s3bucket.aws_s3_bucket.un_encrypted_bucket[0] will be created
  + resource "aws_s3_bucket" "un_encrypted_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "dev-us-east-1-mybucket"
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

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

<br><br><br>

## :large_blue_circle: s3_bucket_suffix_list

<br>

![Optional](images/neon_optional.png)

<br>

This list variable should contain the values of any suffix that you want to append to the end of the requested S3 bucket. Specifying any sequence of values to the list will change the calculated bucket name by adding each of the specified values with a hyphen to the end of the supplied s3_bucket_name.

<br>

__Note: Special s3_bucket_suffix_list Keywords:__

* `region_suffix`: Adding this keyword to the bucket prefix list will result in the resolution of the desired or current execution region, and will place that region into the bucket name string.

* `account_suffix`: Adding this keyword to the bucket prefix list will result in the resolution of the current execution region, and will place that account Id into the bucket name string.

<br><br>

### Declaration in module variables.tf

```terraform
variable "s3_bucket_suffix_list" {
  type        = list
  description = "A suffix list that will be added to the end of the bucket name. For example if s3_bucket_suffix_list=['test'], then the bucket will be named '$${s3_bucket_name}-test'. This module will also look for the keywords 'region_suffix' and 'account_suffix' and will substitute the current region, or account_id within the module as in the example: s3_bucket_suffix_list=['region_suffix', 'account_suffix', 'test'], resulting in the bucket name '$${s3_bucket_name}-us-east-1-1234567890101-test'. If left blank no suffix will be added."
  default     = []
}
```

<br><br>

### Module usage in project root main.tf

```terraform
module "s3_bucket" {
  source = "git@github.com:CloudMage-TF/AWS-S3Bucket-Module?ref=v1.1.0"

  // Required Variables
  s3_bucket_name              = "myBucket"
  s3_bucket_region            = "us-east-1"
  s3_bucket_suffix_list       = ["account_suffix", "w00t"]

  // Optional Variables with module defined default values assigned
  # s3_bucket_prefix_list       = []
}
```

<br><br>

### Example `terraform plan` output

```terraform
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

module.demo_s3bucket.data.aws_caller_identity.current: Refreshing state...
module.demo_s3bucket.data.aws_region.current: Refreshing state...
module.demo_s3bucket.data.aws_iam_policy_document.this: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.demo_s3bucket.aws_s3_bucket.un_encrypted_bucket[0] will be created
  + resource "aws_s3_bucket" "un_encrypted_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "mybucket-987303449646-w00t"
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

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

<br>

> __Note:__ You can use any combination of prefix and suffix values together to create a unique account-specific bucket path.

<br><br>

### Module usage in project root main.tf in project root main.tf using prefix and suffix combination

```terraform
module "s3_bucket" {
  source = "git@github.com:CloudMage-TF/AWS-S3Bucket-Module?ref=v1.1.0"

  // Required Variables
  s3_bucket_name              = "myBucket"
  s3_bucket_region            = "us-east-1"
  s3_bucket_prefix_list       = ["dev", "account_prefix"]
  s3_bucket_suffix_list       = ["region_suffix", "w00t"]
}
```

<br><br>

### Example `terraform plan` output

```terraform
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

module.demo_s3bucket.data.aws_caller_identity.current: Refreshing state...
module.demo_s3bucket.data.aws_region.current: Refreshing state...
module.demo_s3bucket.data.aws_iam_policy_document.this: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.demo_s3bucket.aws_s3_bucket.un_encrypted_bucket[0] will be created
  + resource "aws_s3_bucket" "un_encrypted_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "dev-123456789101-mybucket-us-east-1-w00t"
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

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

<br><br><br>

## :large_blue_circle: s3_versioning_enabled

<br>

![Optional](images/neon_optional.png)

<br>

This variable will turn flag versioning on or off on the bucket. It is important to note that once versioning is turned on within S3 for a given bucket, it can be later disabled, but never removed.

<br><br>

### Declaration in module variables.tf

```terraform
variable "s3_versioning_enabled" {
  type        = bool
  description = "Flag to enable bucket object versioning."
  default     = false
}
```

<br><br>

### Module usage in project root main.tf

```terraform
module "s3_bucket" {
  source = "git@github.com:CloudMage-TF/AWS-S3Bucket-Module?ref=v1.1.0"

  // Required Variables
  s3_bucket_name              = "myBucket"
  s3_bucket_region            = "us-east-1"
  s3_versioning_enabled       = true

  // Optional Variables with module defined default values assigned
  # s3_bucket_prefix_list       = []
  # s3_bucket_suffix_list       = []
}
```

<br><br>

### Example `terraform plan` output

```terraform
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

module.demo_s3bucket.data.aws_caller_identity.current: Refreshing state...
module.demo_s3bucket.data.aws_region.current: Refreshing state...
module.demo_s3bucket.data.aws_iam_policy_document.this: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.demo_s3bucket.aws_s3_bucket.un_encrypted_bucket[0] will be created
  + resource "aws_s3_bucket" "un_encrypted_bucket" {
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
          + enabled    = true
          + mfa_delete = false
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

<br><br><br>

## :large_blue_circle: s3_mfa_delete

<br>

![Optional](images/neon_optional.png)

<br>

This variable will flag the requirement for MFA authentication before removing an object version or suspending versioning within a bucket that has versioning enabled.

<br><br>

### Declaration in module variables.tf

```terraform
variable "s3_mfa_delete" {
  type        = bool
  description = "Flag to enable the requirement of MFA in order to delete an object version, or disable object versioning once versioning has been enabled."
  default     = false
}
```

<br><br>

### Module usage in project root main.tf

```terraform
module "s3_bucket" {
  source = "git@github.com:CloudMage-TF/AWS-S3Bucket-Module?ref=v1.1.0"

  // Required Variables
  s3_bucket_name              = "myBucket"
  s3_bucket_region            = "us-east-1"
  s3_versioning_enabled       = true
  s3_mfa_delete               = true

  // Optional Variables with module defined default values assigned
  # s3_bucket_prefix_list       = []
  # s3_bucket_suffix_list       = []
}
```

<br><br>

### Example `terraform plan` output

```terraform
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

module.demo_s3bucket.data.aws_region.current: Refreshing state...
module.demo_s3bucket.data.aws_caller_identity.current: Refreshing state...
module.demo_s3bucket.data.aws_iam_policy_document.this: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.demo_s3bucket.aws_s3_bucket.un_encrypted_bucket[0] will be created
  + resource "aws_s3_bucket" "un_encrypted_bucket" {
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
          + enabled    = true
          + mfa_delete = true
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

<br><br><br>

## :large_blue_circle: s3_bucket_acl

<br>

![Optional](images/neon_optional.png)

<br>

This variable is used to pass the desired permissions of the bucket at the time of provisioning the bucket. The default value is set to private but can be changed by providing a valid permission keyword as the value for the s3_bucket_acl variable. Valid values for this variable are as follows:

* __private__ - Owner gets FULL_CONTROL. No one else has access rights (default).
* __public-read__ - Owner gets FULL_CONTROL. The AllUsers group gets READ access.
* __public-read-write__ - Owner gets FULL_CONTROL. The AllUsers group gets READ and WRITE access. Not generally recommended.
* __aws-exec-read__ - Owner gets FULL_CONTROL. EC2 gets READ access to GET an AMI bundle from Amazon S3.
* __authenticated-read__ - Owner gets FULL_CONTROL. The AuthenticatedUsers group gets READ access.
* __bucket-owner-read__ - Object owner gets FULL_CONTROL. Bucket owner gets READ access.
* __bucket-owner-full-control__ - Both the object owner and the bucket owner get FULL_CONTROL over the object.
* __log-delivery-write__ - The LogDelivery group gets WRITE and READ_ACP permissions on the bucket.

<br><br>

### Declaration in module variables.tf

```terraform
variable "s3_bucket_acl" {
  type        = string
  description = "The Access Control List that will be placed on the bucket. Acceptable Values are: 'private', 'public-read', 'public-read-write', 'aws-exec-read', 'authenticated-read', 'bucket-owner-read', 'bucket-owner-full-control', or 'log-delivery-write'"
  default     = "private"
```

<br><br>

### Module usage in project root main.tf

```terraform
module "s3_bucket" {
  source = "git@github.com:CloudMage-TF/AWS-S3Bucket-Module?ref=v1.1.0"

  // Required Variables
  s3_bucket_name              = "myBucket"
  s3_bucket_region            = "us-east-1"
  s3_bucket_acl               = "bucket-owner-read"

  // Optional Variables with module defined default values assigned
  # s3_bucket_prefix_list       = []
  # s3_bucket_suffix_list       = []
  # s3_versioning_enabled       = false
  # s3_mfa_delete               = false
}
```

<br><br>

### Example `terraform plan` output

```terraform
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

module.demo_s3bucket.data.aws_caller_identity.current: Refreshing state...
module.demo_s3bucket.data.aws_region.current: Refreshing state...
module.demo_s3bucket.data.aws_iam_policy_document.this: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.demo_s3bucket.aws_s3_bucket.un_encrypted_bucket[0] will be created
  + resource "aws_s3_bucket" "un_encrypted_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = "bucket-owner-read"
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

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

<br><br><br>

## :large_blue_circle: s3_encryption_enabled

<br>

![Optional](images/neon_optional.png)

<br>

This variable is a flag if encryption should be configured on the requested bucket. Setting this value to true will automatically turn on encryption on the bucket at the time of provisioning using the default S3/AES256 AWS managed KMS Key.

<br>

> __Note:__ It will also automatically create a bucket policy that will be attached to the bucket forcing encryption in transit on PUT.

<br><br>

### Declaration in module variables.tf

```terraform
variable "s3_encryption_enabled" {
  type        = bool
  description = "Flag to enable bucket object encryption."
  default     = false
}
```

<br><br>

### Module usage in project root main.tf

```terraform
module "s3_bucket" {
  source = "git@github.com:CloudMage-TF/AWS-S3Bucket-Module?ref=v1.1.0"

  // Required Variables
  s3_bucket_name              = "myBucket"
  s3_bucket_region            = "us-east-1"
  s3_encryption_enabled       = true

  // Optional Variables with module defined default values assigned
  # s3_bucket_prefix_list       = []
  # s3_bucket_suffix_list       = []
  # s3_versioning_enabled       = false
  # s3_mfa_delete               = false
  # s3_bucket_acl               = "private"
}
```

<br>

> __Note:__ Setting the `s3_encryption_enabled` option to true will automatically add the following bucket policy to the bucket at the time of provisioning:

<br><br>

### Generated Bucket Policy

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
```

<br><br>

### Example `terraform plan` output

```terraform
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

module.demo_s3bucket.data.aws_caller_identity.current: Refreshing state...
module.demo_s3bucket.data.aws_region.current: Refreshing state...
module.demo_s3bucket.data.aws_iam_policy_document.this: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.demo_s3bucket.aws_s3_bucket.encrypted_bucket[0] will be created
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
                      + Resource  = [
                          + "arn:aws:s3:::mybucket/*",
                          + "arn:aws:s3:::mybucket",
                        ]
                      + Sid       = "DenyNonSecureTransport"
                    }
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
                  + sse_algorithm = "AES256"
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

<br><br><br>

## :large_blue_circle: s3_kms_key_arn

<br>

![Optional](images/neon_optional.png)

<br>

This variable is used to define an existing KMS CMK that is preferred to encrypt objects into the bucket. Using a CMK instead of the default AWS Managed KMS key allows more granular control over the permissions of the encryption key used to encrypt the objects within the bucket.

<br><br>

### Declaration in module variables.tf

```terraform
variable "s3_kms_key_arn" {
  type        = string
  description = "The key that will be used to encrypt objects within the new bucket. If the default value of AES256 is unchanged, S3 will encrypt objects with the default KMS key. If a KMS CMK ARN is provided, then S3 will encrypt objects with the specified KMS key instead."
  default     = "AES256"
}
```

<br>

> __Note:__ When supplying a KMS CMK Key ARN, the bucket encryption type will automatically switch from **AES256** to **aws:kms**. Encryption will work the same way, only using the provided key instead of the Amazon managed default S3 key. The bucket policy shown above will also still be applied.

<br><br>

### Module usage in project root main.tf

```terraform
module "s3_bucket" {
  source = "git@github.com:CloudMage-TF/AWS-S3Bucket-Module?ref=v1.1.0"

  // Required Variables
  s3_bucket_name              = "myBucket"
  s3_bucket_region            = "us-east-1"
  s3_encryption_enabled       = true
  s3_kms_key_arn              = "arn:aws:kms:us-east-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"

  // Optional Variables with module defined default values assigned
  # s3_bucket_prefix_list       = var.s3_bucket_prefix_list
  # s3_bucket_suffix_list       = var.s3_bucket_suffix_list
  # s3_versioning_enabled       = var.s3_versioning_enabled
  # s3_mfa_delete               = var.s3_mfa_delete
  # s3_bucket_acl               = "private"
}
```

<br><br>

### Example `terraform plan` output

```terraform
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

module.demo_s3bucket.data.aws_caller_identity.current: Refreshing state...
module.demo_s3bucket.data.aws_region.current: Refreshing state...
module.demo_s3bucket.data.aws_iam_policy_document.this: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.demo_s3bucket.aws_s3_bucket.encrypted_bucket[0] will be created
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
                      + Resource  = [
                          + "arn:aws:s3:::mybucket/*",
                          + "arn:aws:s3:::mybucket",
                        ]
                      + Sid       = "DenyNonSecureTransport"
                    }
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
                  + kms_master_key_id = "arn:aws:kms:us-east-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
                  + sse_algorithm     = "aws:kms"
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

<br><br><br>







## :large_blue_circle: s3_bucket_tags

<br>

![Optional](images/neon_optional.png)

<br>

This variable should contain a map of tags that will be assigned to the S3 bucket upon creation. Any tags contained within the `s3_bucket_tags` map variable will be passed to the module and automatically merged with a few tags that are also automatically created when the module is executed. The automatically generated tags are as follows:

* __Name__ - This tag is assigned the value from the `s3_bucket_name` required variable that is passed during module execution
* __Created_By__ - This tag is assigned the value of the aws user that was used to execute the Terraform module to create the S3 bucket. It uses the Terraform `aws_caller_identity {}` data source provider to obtain the User_Id value. This tag will be ignored for any future executions of the module, ensuring that its value will not be changed after it's initial creation.
* __Creator_ARN__ - This tag is assigned the ARN value of the aws user that was used to execute the Terraform module to create the S3 Bucket. It uses the Terraform `aws_caller_identity {}` data source provider to obtain the User_ARN value. This tag will be ignored for any future executions of the module, ensuring that its value will not be changed after it's initial creation.
* __Creation_Date__ - This tag is assigned a value that is obtained by the Terraform `timestamp()` function. This tag will be ignored for any future executions of the module, ensuring that its value will not be changed after it's initial creation.
* __Updated_On__ - This tag is assigned a value that is obtained by the Terraform `timestamp()` function. This tag will be updated on each future execution of the module to ensure that it's value displays the last `terraform apply` date.
* __Encrypted__ - This tag is assigned the value from the `s3_encryption_enabled` variable. If the consumer of the module did not flag the encryption option, then by default the value of the s3_encryption_enabled variable is set to `false`.
* __CMK_ARN__ - This tag is assigned the value from the `s3_kms_key_arn` variable if provisioning an encrypted bucket. If the bucket is not encrypted this tag will be excluded. If encryption was enabled and a kms cmk was not passed, then the tag will indicate that encryption is configured using the default aws/s3 managed key.

<br><br>

### Declaration in module variables.tf

```terraform
variable "s3_bucket_tags" {
  type        = map
  description = "Specify any tags that should be added to the S3 bucket being provisioned."
  default     = {
    Provisoned_By  = "Terraform"
    GitHub_URL     = "https://github.com/CloudMage-TF/AWS-S3Bucket-Module.git"
  }
}
```

<br><br>

### Module usage in project root main.tf

```terraform
module "s3_bucket" {
  source = "git@github.com:CloudMage-TF/AWS-S3Bucket-Module?ref=v1.1.0"

  // Required Variables
  s3_bucket_name              = "myBucket"
  s3_bucket_region            = "us-east-1"

  // Tags
  kms_tags = {
     Provisoned_By  = "Terraform"
     GitHub_URL     = "https://github.com/CloudMage-TF/AWS-S3Bucket-Module.git"
     Environment    = "Prod"
   }

  // Optional Variables with module defined default values assigned
  # s3_bucket_prefix_list       = var.s3_bucket_prefix_list
  # s3_bucket_suffix_list       = var.s3_bucket_suffix_list
  # s3_versioning_enabled       = var.s3_versioning_enabled
  # s3_mfa_delete               = var.s3_mfa_delete
  # s3_bucket_acl               = "private"
  # s3_encryption_enabled       = false
  # s3_kms_key_arn              = "AES256"
}
```

<br><br>

# Module Example Usage

An example of how to use this module can be found within the `example` directory of this repository

<br><br>

# Variables and TFVars File Templates

The following code block can be used or appended to an existing tfvars file within the project root consuming this module. Optional Variables are commented out and have their values set to the default values defined in the modules variables.tf file. If the values do not need to be changed, then they do not need to be redefined in the project root. If they do need to be changed, then include them in the root project and change the values accordingly.

<br><br>

## Complete Module variables.tf File

```terraform
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
```

<br><br>

## Complete Module TFVars File

```terraform
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
s3_bucket_region      = "empty"
s3_bucket_prefix_list = []
s3_bucket_suffix_list = []
s3_versioning_enabled = false
s3_mfa_delete         = false
s3_encryption_enabled = false
s3_kms_key_arn        = "AES256"
s3_bucket_acl         = "private"

s3_bucket_tags        = {
    Provisoned_By  = "Terraform"
    GitHub_URL     = "https://github.com/CloudMage-TF/AWS-S3Bucket-Module.git"
}
```

<br><br>

# Module Outputs

The template will finally create the following outputs that can be pulled and used in subsequent terraform runs via data sources. The outputs will be written to the Terraform state file.

<br>

```terraform
######################
# S3 Bucket Outputs  #
######################
output "s3_bucket_id" {}
output "s3_bucket_arn" {}
output "s3_bucket_domain_name" {}
output "s3_bucket_region" {}
```

<br><br>

# Module Output Usage

When using and calling the module within a root project, the output values of the module are available to the project root by simply referencing the module outputs from the root project `outputs.tf` file.

<br>

```terraform
######################
# S3 Bucket Outputs  #
######################
output "bucket_id" {
  value = module.s3bucket.s3_bucket_id
}

output "bucket_arn" {
  value = module.s3bucket.s3_bucket_arn
}

output "bucket_domain_name" {
  value = module.s3bucket.s3_bucket_domain_name
}

output "bucket_region" {
  value = module.s3bucket.s3_bucket_region
}
```

<br>

> __Note:__ When referencing the module outputs be sure that the output value contains the identifier given to the module call. As an example if the module was defined as `module "demo_s3bucket" {}` then the output reference would be constructed as `module.demo_s3bucket.s3_bucket_arn`.

<br><br>

# Requirements

* [Terraform](https://www.terraform.io/)
* [GIT](https://git-scm.com/download/win)
* [AWS-Account](https://https://aws.amazon.com/)

<br><br>

# Recommended

* [Terraform for VSCode](https://github.com/mauve/vscode-terraform)
* [Terraform Config Inspect](https://github.com/hashicorp/terraform-config-inspect)

<br><br>

# Contacts and Contributions

This project is owned by [CloudMage](rnason@cloudmage.io).

To contribute, please:

* Fork the project
* Create a local branch
* Submit Changes
* Create A Pull Request
