terraform {
  required_providers {
    neon = {
      source  = "terraform-community-providers/neon"
      version = "~> 0.1.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.21.0"
    }
  }
}

# Configure the Neon Provider
provider "neon" {
  api_key = var.neon_api_key
}

# Neon Project
resource "neon_project" "text_notifications" {
  name      = "text-notifications"
  region_id = "aws-us-east-1"
}

# Neon Role
resource "neon_role" "app_role" {
  name       = "app_user"
  branch_id  = neon_branch.main.id
  project_id = neon_project.text_notifications.id
}

# Create the database
resource "neon_database" "notifications_db" {
  project_id = neon_project.text_notifications.id
  name       = "text_notifications_db"
  owner      = "app_user"
}

# Configure the PostgreSQL Provider to connect to Neon
provider "postgresql" {
  host            = neon_project.text_notifications.database_host
  port            = 5432
  database        = neon_database.notifications_db.name
  username        = neon_database.notifications_db.owner
  password        = neon_project.text_notifications.database_password
  sslmode         = "require"
  connect_timeout = 15
}

# Apply schema using PostgreSQL provider
resource "postgresql_schema" "app_schema" {
  name  = "public"
  owner = neon_database.notifications_db.owner
}

# Apply the SQL schema file
resource "postgresql_query" "schema" {
  depends_on = [postgresql_schema.app_schema]
  query      = file("${path.module}/schema.sql")
}
