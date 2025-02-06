/*
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.19.0"
    }

  }
}
*/

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = file("${var.project_id}.json")
}
