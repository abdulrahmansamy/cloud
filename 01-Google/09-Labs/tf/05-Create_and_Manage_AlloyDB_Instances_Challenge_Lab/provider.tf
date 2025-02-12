provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = file("${var.project_id}.json")
}

terraform {
  required_version = ">= 1.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.32, < 7"
    }
  }

  provider_meta "google" {
    module_name = "blueprints/terraform/terraform-google-alloy-db/v3.2.1"
  }
}





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