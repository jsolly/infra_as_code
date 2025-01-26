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

provider "neon" {
  api_key = var.neon_api_key
}

resource "neon_project" "text_notifications" {
  name      = "text-notifications"
  region_id = var.aws_region
}

resource "neon_role" "app_role" {
  name       = "app_user"
  branch_id  = neon_branch.main.id
  project_id = neon_project.text_notifications.id
}

resource "neon_database" "notifications_db" {
  project_id = neon_project.text_notifications.id
  name       = "text_notifications_db"
  owner      = "app_user"
}
provider "postgresql" {
  host            = neon_project.text_notifications.database_host
  port            = 5432
  database        = neon_database.notifications_db.name
  username        = neon_database.notifications_db.owner
  password        = neon_project.text_notifications.database_password
  sslmode         = "require"
  connect_timeout = 15
}

resource "postgresql_schema" "app_schema" {
  name  = "public"
  owner = neon_database.notifications_db.owner
}

resource "postgresql_query" "schema" {
  depends_on = [postgresql_schema.app_schema]
  query      = file("${path.module}/schema.sql")
}
