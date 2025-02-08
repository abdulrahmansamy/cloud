provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_alloydb_cluster" "existing_cluster" {
  name    = var.cluster_id
  project = var.project_id
  region  = var.region
}

resource "google_alloydb_instance" "read_pool_instances" {
  count        = var.read_pool_instance_count
  cluster      = data.google_alloydb_cluster.existing_cluster.id
  instance_id  = "read-pool-instance-${count.index}"
  region       = var.region
  project      = var.project_id
  machine_type = var.machine_type
  instance_type = "READ_POOL"
}

output "read_pool_instances" {
  value = google_alloydb_instance.read_pool_instances
}
