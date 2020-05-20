resource "google_compute_network" "vpc_network" {
  name                    = "crypto-tracker-vpc-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "general_subnet" {
  name                      = "general-subnet"
  ip_cidr_range             = "10.132.0.0/20"
  region                    = var.region
  network                   = google_compute_network.vpc_network.self_link
  private_ip_google_access  = true
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
      ipv4_enabled    = true
      private_network = google_compute_network.vpc_network.self_link

      authorized_networks {
        value = "82.26.122.26/32"
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

resource "google_container_cluster" "gke_cluster" {
  name                      = "crypto-tracker-cluster"
  location                  = var.zone
  remove_default_node_pool  = true
  initial_node_count        = 1
  network                   = google_compute_network.vpc_network.self_link
  subnetwork                = google_compute_subnetwork.general_subnet.self_link

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "10.2.0.0/28"
  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block = ""
    services_ipv4_cidr_block = ""
  }

}

resource "google_container_node_pool" "gke_node_pool" {
  name       = "gke-node-pool"
  cluster    = google_container_cluster.gke_cluster.name
  node_count = 2
}

resource "google_storage_bucket" "bucket-prices" {
  name          = "crypto-tracker-prices"
  location      = "EU"
  versioning {
    enabled     = true
  }
}

resource "google_compute_router" "crypto_router" {
  name    = "crypto-router"
  region  = var.region
  network = google_compute_network.vpc_network.id
}

resource "google_compute_router_nat" "crypto_route_nat" {
  name                               = "crypto-route-nat"
  router                             = google_compute_router.crypto_router.name
  region                             = google_compute_router.crypto_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

