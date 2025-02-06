terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.19.0"
    }

  }
}


provider "google" {
  project     = "qwiklabs-gcp-03-406aa89dadcb"
  region      = "us-east1"
  zone        = "us-east1-d"
  credentials = file("gcp_key.json")
}