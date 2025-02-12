
/*
data "google_alloydb_cluster" "existing_cluster" {
  name    = var.cluster_id
  project = var.project_id
  region  = var.region
}


resource "google_alloydb_instance" "existing_cluster" {
  cluster       = "projects/${var.project_id}/locations/${var.region}/clusters/${var.cluster_id}"
  instance_id   = "projects/${var.project_id}/locations/${var.region}/clusters/${var.cluster_id}/instances/${var.instance_id}"
  instance_type = "PRIMARY"

}

resource "google_alloydb_instance" "existing_cluster" {
  cluster       = "${var.cluster_id}"
  instance_id   = "${var.instance_id}"
  instance_type = "PRIMARY"

}

import {
  id = "projects/${var.project_id}/locations/${var.region}/clusters/${var.cluster_id}"
  to = module.alloy-db.google_alloydb_cluster.default
}

import {
  id = "projects/${var.project_id}/locations/${var.region}/clusters/${var.cluster_id}/instances/${var.instance_id}"
  to = module.alloy-db.google_alloydb_instance.primary
}
*/

/*
import {
  id = "projects/${var.project_id}/locations/${var.region}/clusters/${var.cluster_id}/instances/${var.instance_id}"
  to = google_alloydb_instance.existing_cluster
}
*/
module "alloy-db" {
  source  = "GoogleCloudPlatform/alloy-db/google"
  version = "~> 3.0"

  primary_instance         = var.primary_instance
  cluster_id               = var.cluster_id
  cluster_location         = var.region
  project_id               = var.project_id
  network_self_link        = "projects/${var.project_id}/global/networks/${var.network_name}"
  continuous_backup_enable = true
  cluster_initial_user     = var.admin_user

  read_pool_instance = [
    {
      instance_id  = var.read_pool_instance_id
      display_name = var.read_pool_instance_id
      #require_connectors = false
      #ssl_mode           = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
      cpu_count  = 2
      node_count = 1
    }
  ]
  /* 
  automated_backup_policy = {
    location      = var.region
    # backup_window = "1800s",
    enabled       = true,
    
    weekly_schedule = {
      days_of_week = ["FRIDAY"],
      start_times  = ["2:00:00:00", ]
    }
    
    quantity_based_retention_count = 1,
    time_based_retention_count     = null,
    
    labels = {
      test = var.backup_id
    },
  } 
  */
}

/*
resource "google_alloydb_instance" "read_pool_instances" {
  count       = var.read_pool_instance_count
  cluster     = "${var.project_id}/${var.region}/${var.cluster_id}"
  instance_id = "${var.read_pool_instance_id}${count.index + 1}"

  instance_type = "READ_POOL"
  read_pool_config {
    node_count = var.read_pool_instance_node_count
  }
  machine_config {
    cpu_count = var.cpu_count
  }
  depends_on = [module.alloy-db]
}

*/
resource "google_alloydb_backup" "alloydb_backup" {
  location     = var.region
  backup_id    = var.backup_id
  cluster_name = var.cluster_id
  project      = var.project_id
  depends_on   = [module.alloy-db]
  # depends_on = [google_alloydb_instance.read_pool_instances]

}
