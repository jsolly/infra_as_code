output "project_id" {
  description = "The ID of the Neon project"
  value       = neon_project.text_notifications.id
}

output "database_name" {
  description = "The name of the created database"
  value       = neon_database.notifications_db.name
}

output "database_owner" {
  description = "The owner of the database"
  value       = neon_database.notifications_db.owner
}

output "database_url" {
  description = "The connection string for the database"
  value       = "postgres://${neon_database.notifications_db.owner}:${neon_project.text_notifications.database_password}@${neon_project.text_notifications.database_host}/${neon_database.notifications_db.name}"
  sensitive   = true
}

output "database_host" {
  description = "The host address of the database"
  value       = neon_project.text_notifications.database_host
}

output "branch_id" {
  description = "The ID of the main branch"
  value       = neon_branch.main.id
}

output "role_name" {
  description = "The name of the application database role"
  value       = neon_role.app_role.name
}
