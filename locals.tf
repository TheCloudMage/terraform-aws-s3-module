######################
# Local Variables:   #
######################
locals {
  // If a Prefix list was supplied then join it together, and append the passed bucket name.
  prefixed_bucket_name = <<EOS
%{~if length(var.bucket_prefix) > 0~}
${replace(replace(format("%s-%s", join("-", var.bucket_prefix), var.bucket), "region_prefix", var.region), "account_prefix", data.aws_caller_identity.current.account_id)}
%{~else~}
${var.bucket}
%{~endif~}
EOS

  // If a Suffix list was supplied then join it together, and prepend the already prefixed bucket name.
  suffixed_bucket_name = <<EOS
%{~if length(var.bucket_suffix) > 0~}
${replace(replace(format("%s-%s", local.prefixed_bucket_name, join("-", var.bucket_suffix)), "region_suffix", var.region), "account_suffix", data.aws_caller_identity.current.account_id)}
%{~else~}
${local.prefixed_bucket_name}
%{~endif~}
EOS

  // Set the bucket name
  bucket_name = trimspace(lower(local.suffixed_bucket_name))

  // Bucket name to hold S3 access logs (buckets are in AccountBaseline)
  log_bucket_name = var.logging_bucket != null ? trimspace(lower(var.logging_bucket)) : null

  // Set Encryption Setting
  sse_algorithm = var.kms_master_key_id == "AES256" ? "AES256" : "aws:kms"
}