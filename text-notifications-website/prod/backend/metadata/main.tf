module "metadata" {
  source              = "../../../../modules/backend/metadata"
  metadata_table_name = var.metadata_table_name
}

output "metadata_table_name" {
  value = module.metadata.table_name
}

output "metadata_table_arn" {
  value = module.metadata.table_arn
}
