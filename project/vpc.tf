resource "google_compute_network" "vpc_network" {
  count                   = contains(["prod"], var.env) ? 1 : 0
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "general_subnet" {
  count                     = contains(["prod"], var.env) ? 1 : 0
  name                      = "general-subnet"
  ip_cidr_range             = "10.132.0.0/20"
  region                    = var.region
  network                   = local.vpc_uri
  private_ip_google_access  = true
}

resource "google_compute_global_address" "cloudsql_ip_alloc" {
  count         = contains(["staging", "prod"], var.env) ? 1 : 0
  name          = "${var.cloudsql_ip_alloc}-${var.env}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = local.vpc_uri
}

resource "google_service_networking_connection" "cloudsql_network_connection" {
  count                   = contains(["staging", "prod"], var.env) ? 1 : 0
  network                 = local.vpc_uri
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [
    for env in ["staging", "prod"]:
          "${var.cloudsql_ip_alloc}-${env}"
  ]
}

resource "google_compute_router" "crypto_router" {
  count   = contains(["prod"], var.env) ? 1 : 0
  name    = "crypto-router"
  region  = var.region
  network = local.vpc_uri
}

resource "google_compute_router_nat" "crypto_route_nat" {
  count                              = contains(["prod"], var.env) ? 1 : 0
  name                               = "crypto-route-nat"
  router                             = google_compute_router.crypto_router[count.index].name
  region                             = google_compute_router.crypto_router[count.index].region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
