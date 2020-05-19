provider "google" {
  credentials = var.credentials_path
  project     = var.project
  region      = var.region
  zone        = var.zone
}

provider "google-beta" {
  credentials = var.credentials_path
  project     = var.project
  region      = var.region
  zone        = var.zone
}

resource "google_storage_bucket" "terraform-state-bucket" {
  name          = "crypto-tracker-terraform-state"
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

  backend "gcs" {
    credentials = "creds.json"
    bucket  = "crypto-tracker-terraform-state"
  }
}
