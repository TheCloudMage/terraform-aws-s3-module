# CloudMage TF-AWS-S3Bucket-Module CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<br>

## 1.0.3 - [2020-01-19]

### Added

- Example project using the module has been added to the repository

### Changed

- Renamed the not_encrypted_bucket module resource to un_encrypted_bucket
- Changed non constant expressions in module to fix interpolation-only expression deprecation warning ${var.s3_var} -> var.s3_var

### Removed

- v1.0.2 removed to fix interpolation warnings

- None

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
