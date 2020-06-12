provider "google" {
  project     = var.project
  region      = var.region
  zone        = var.zone
}

provider "google-beta" {
  project     = var.project
  region      = var.region
  zone        = var.zone
}

resource "google_storage_bucket" "terraform-state-bucket" {
  name          = var.state_bucket
  location      = "EU"
  versioning {
    enabled     = true
  }
}

terraform {
  required_version = ">= 0.12"

  required_providers {
    google-beta = ">= 3.8"
  }

}
