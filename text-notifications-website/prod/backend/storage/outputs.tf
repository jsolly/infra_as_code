output "asset_storage_bucket_arn" {
  value = module.asset_storage.bucket_arn
}

output "asset_storage_bucket_name" {
  value = module.asset_storage.bucket_name
}

output "lambda_code_storage_bucket_arn" {
  value = module.lambda_code_storage.bucket_arn
}
