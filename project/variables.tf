variable "env" {
}

variable "project" {
}

variable "region" {
}

variable "zone" {
}

variable "vpc_name" {
}

variable "cloudsql_ip_alloc" {
}

locals {
  vpc_uri = "projects/${var.project}/global/networks/${var.vpc_name}"
}
