<!-- VSCode Markdown Exclusions-->
<!-- markdownlint-disable MD024 Multiple Headings with the Same Content-->
# CloudMage TF-AWS-S3Bucket-Module CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<br>

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
