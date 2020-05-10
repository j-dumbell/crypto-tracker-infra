resource "google_compute_network" "vpc_network" {
  name = "crypto-tracker-vpc-network"
}

resource "google_compute_global_address" "cloudsql_ip_alloc" {
  name          = "cloudsql-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = google_compute_network.vpc_network.self_link
}

resource "google_service_networking_connection" "cloudsql_network_connection" {
  network                 = google_compute_network.vpc_network.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.cloudsql_ip_alloc.name]
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "backend_db" {
  name              = "backend-db-${random_id.db_name_suffix.hex}"
  database_version  = "POSTGRES_11"
  depends_on = [google_service_networking_connection.cloudsql_network_connection]

  settings {
    tier            = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc_network.self_link
    }

  }
}
