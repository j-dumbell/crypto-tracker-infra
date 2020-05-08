provider "google" {
  project = "big-quanta-276615"
  region  = "europe-west2"
  zone    = "europe-west2-a"
}

resource "google_storage_bucket" "terraform-state-bucket" {
  name          = "crypto-tracker-terraform-state"
  location      = "EU"
}