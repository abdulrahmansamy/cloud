
data "google_alloydb_cluster" "existing_cluster" {
  name    = var.cluster_id
  project = var.project_id
  region  = var.region
}

resource "google_alloydb_instance" "read_pool_instances" {
  count       = var.read_pool_instance_count
  cluster     = data.google_alloydb_cluster.existing_cluster.id
  instance_id = "read-pool-instance-${count.index}"

  instance_type = "READ_POOL"
  read_pool_config {
    node_count = var.read_pool_instance_node_count
  }
  machine_config {
    cpu_count = var.cpu_count
  }
}


resource "google_alloydb_backup" "alloydb_backup" {
  location     = var.region
  backup_id    = var.backup_id
  cluster_name = data.google_alloydb_cluster.existing_cluster.id

  depends_on = [google_alloydb_instance.read_pool_instances]
}
