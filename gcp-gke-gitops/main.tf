terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_container_cluster" "gke" {
  name     = "${var.project}-gke"
  location = var.region
  initial_node_count = 1

  remove_default_node_pool = true
  network    = "default"
  subnetwork = "default"
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-pool"
  location   = var.region
  cluster    = google_container_cluster.gke.name
  node_count = 1
  node_config {
    machine_type = "e2-standard-2"
  }
}

output "cluster_name" { value = google_container_cluster.gke.name }
