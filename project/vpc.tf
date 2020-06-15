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
  name          = "cloudsql-ip-alloc-${var.env}"
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