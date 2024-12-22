output "nasa_photo_fetcher_function_arn" {
  value = module.nasa_photo_fetcher.lambda_function_arn
}

output "nasa_photo_fetcher_function_name" {
  value = module.nasa_photo_fetcher.lambda_function_name
}

output "nasa_photo_fetcher_s3_hash" {
  description = "The raw ETag from S3 object"
  value       = module.nasa_photo_fetcher.s3_raw_hash
}

output "photo_sender_function_arn" {
  value = module.nasa_photo_sender.lambda_function_arn
}

output "photo_sender_function_name" {
  value = module.nasa_photo_sender.lambda_function_name
}
