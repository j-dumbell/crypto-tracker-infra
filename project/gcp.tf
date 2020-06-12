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

terraform {
  required_version = ">= 0.12"

  required_providers {
    google-beta = ">= 3.8"
  }

  backend "gcs" {
    bucket  = "basdasdas"
  }
}