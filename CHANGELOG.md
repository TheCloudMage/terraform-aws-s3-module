<!-- VSCode Markdown Exclusions-->
<!-- markdownlint-disable MD024 Multiple Headings with the Same Content-->
# CloudMage TF-AWS-S3Bucket-Module CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<br>

## v1.3.0 - [2020-06-15]

### Added

- Additional variable module_enabled to control module provisioning added and updated in corresponding module resource
- Logging Bucket variable added to allow the configuration of S3 bucket access logging.
- static_hosting, index, and error variables added to allow the bucket to be configured as a static S3 hosting bucket.
- cors variable added to allow the passing of Cross Origin Resource Sharing rules.
- policy and policy_override variables added to allow custom policies to be added to the bucket policy, or to allow a custom policy to simply override the constructed bucket policy with one that is provided by the user instead.

### Changed

- Outputs changed to consume the now single bucket `this`
- Variables renamed to the standard provider values, instead of for example `s3_bucket_name`, the variable is now just `bucket` to allow easier consumption of the variables by module consumers.
- s3_shared_principal_list replaced with `read_access` and `write_access`. Both variables are used to create and attach cooresponding read/write bucket polices.
- Logging, SSE Configuration, website and CORs configuration all built using dynamic blocks.
- Removed the second S3 resource and logic pertaining to if encrypted use encrypted_bucket resource vs non_encrypted_bucket_resource

### Removed

- None

<br><br>

## v1.2.0 - [2020-01-29]

### Added

- s3_shared_principal_list variable added to hold user/role ARNs that will be granted permissions to GET, PUT, and DELETE objects to/from the provisioned bucket.
- Optional Bucket Policy to allow shared access to the bucket based on an Arn List type variable. The policy will stack on the encrypted policy if bucket is encrypted, or will be added standalone to an unencrypted bucket if user/role ARNs are populated in the s3_shared_principal_list variable.

### Changed

- Outputs renamed to the standard values, instead of for example `s3_bucket_arn`, the output is now just `arn` to allow easier consumption of the outputs by module consumers.
- Fixed all Documentation to address miss-spelled tag
- Readme updated to reflect new sharing list variable and the access that it's usage provides.
- Examles have been changed to reflect new variable, and updated module version.

### Removed

- None

<br><br>

## v1.1.1 - [2020-01-23]

### Added

- None

### Changed

- Provisoned_By tag spelling corrected to Provisioned_By
- Fixed all Documentation to address miss-spelled tag

### Removed

- None

<br><br>

## 1.1.0 - [2020-01-21]

### Added

- Added tagging logic to the s3 bucket resources to give buckets any desired tags.
- Added merge to passed tags to also create Name, Created_By, Creator_ARN, Creation_Date and Updated_On auto tags.
- Lifecycle ignore_changes placed on Created_By, Creator_ARN, and Creation_Date auto tags.
- Updated_On tag unlike the others will automatically update on subsequent terraform apply executions.
- Added tags variable, and set value in example variables.tf and env.tfvars.
- Additional Encrypted tag, that will have a value of true or false depending on if the bucket is encrypted.
- Additional CMK_ARN tag, that will hold the value of the kms encryption key on the encrypted resource version.

### Changed

- Changed outputs to produce single string value instead of list value. This could be breaking change as it changes output format.
- Put variables.tf example variables.tf and env.tfvars into consistant format.

### Removed

- Removed bucket policy statement enforcing --sse option on PUT as encrypted buckets have default encryption enabled.
- Removed bucket policy statement enforcing --sse-kms-key-id on PUT. Bucket has assigned CMK if encrypted bucket.

<br><br>

## 1.0.3 - [2020-01-19]

### Added

- Example project using the module has been added to the repository

### Changed

- Renamed the not_encrypted_bucket module resource to un_encrypted_bucket
- Changed non constant expressions in module to fix interpolation-only expression deprecation warning ${var.s3_var} -> var.s3_var

### Removed

- v1.0.2 removed to fix interpolation warnings

<br><br>

## 1.0.1 - [2019-09-22]

### Added

- None

### Changed

- Fixed region_suffix and account_suffix replace statements

### Removed

- Removed bucket policy resource expression and replaced with var interpolation

<br><br>

## 1.0.0 - [2019-09-22]

### Added

- Functional module initial commit

### Changed

- None

### Removed

- None
