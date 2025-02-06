/*
module "alloydb_east" {
  source  = "GoogleCloudPlatform/alloy-db/google"
  version = "~> 3.2"

  ## Comment this out in order to promote cluster as primary cluster
  primary_cluster_name = module.alloydb_central.cluster_name
  primary_instance     = "lab-instance"

  # primary_cluster_name = module.alloydb_east.cluster_name

  cluster_id       = "lab-cluster"
  cluster_location = var.cluster_location
  project_id       = var.project_id

  network_self_link           = "projects/${var.project_id}/global/networks/${var.network_name}"
  cluster_encryption_key_name = google_kms_crypto_key.key_region1.id

}
*/

module "alloy-db" {
  count = length(var.clusters_list)

  source  = "GoogleCloudPlatform/alloy-db/google"
  version = "~> 3.0"

  primary_instance  = var.clusters_list[count.index].primary_instance
  cluster_id        = var.clusters_list[count.index].cluster_id
  cluster_location  = var.region
  project_id        = var.project_id
  network_self_link = "projects/${var.project_id}/global/networks/${var.network_name}"

  cluster_initial_user = var.admin_user
  /*
  automated_backup_policy = {
    location      = var.region
    backup_window = "1800s"
    enabled       = true
    weekly_schedule = {
      days_of_week = ["FRIDAY"]
      start_times  = ["2:00:00:00"]
    }
    quantity_based_retention_count = 1
  }*/
}

/*
module "alloy-db-gcloud" {
  source  = "GoogleCloudPlatform/alloy-db/google"
  version = "~> 3.0"

  primary_instance  = var.primary_instance
  cluster_id        = var.cluster_id
  cluster_location  = var.region
  project_id        = var.project_id
  network_self_link = "projects/${var.project_id}/global/networks/${var.network_name}"

  cluster_initial_user = var.admin_user

}
*/