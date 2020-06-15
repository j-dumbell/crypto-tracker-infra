resource "google_container_cluster" "gke_cluster" {
  count                     = contains(["prod"], var.env) ? 1 : 0
  name                      = "crypto-tracker-cluster"
  location                  = var.zone
  remove_default_node_pool  = true
  initial_node_count        = 1
  network                   = google_compute_network.vpc_network[count.index].self_link
  subnetwork                = google_compute_subnetwork.general_subnet[count.index].self_link

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
  count      = contains(["prod"], var.env) ? 1 : 0
  name       = "gke-node-pool"
  cluster    = google_container_cluster.gke_cluster[count.index].name

  autoscaling {
    max_node_count = 2
    min_node_count = 0
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_write"
    ]
  }
}
