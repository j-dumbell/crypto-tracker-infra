resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "backend_db" {
  name              = "backend-db-${var.env}-${random_id.db_name_suffix.hex}"
  database_version  = "POSTGRES_11"
  depends_on = [google_service_networking_connection.cloudsql_network_connection]

  settings {
    tier            = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.vpc_network.self_link

      authorized_networks {
        value = "82.17.109.71/32"
      }
    }
  }
}

data "google_secret_manager_secret_version" "pgpassword" {
  provider  = google-beta
  secret    = "PGPASSWORD"
}

resource "google_sql_user" "backend_db_user" {
  name     = "backend-db-user"
  instance = google_sql_database_instance.backend_db.name
  password = data.google_secret_manager_secret_version.pgpassword.secret_data
}

resource "google_storage_bucket" "bucket-prices" {
  name          = "crypto-tracker-prices"
  location      = "EU"
  versioning {
    enabled     = true
  }
}
