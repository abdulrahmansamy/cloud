/*
output "read_pool_instances" {
  value = google_alloydb_instance.read_pool_instances
}



output "read_pool_instances_private_ip_addresses" {
  description = "primary instance public IP"
  value       = google_alloydb_instance.read_pool_instances[*].ip_address
}
*/

output "primary_instance_private_ip_address" {
  description = "primary instance public IP"
  # value       = google_alloydb_instance.existing_cluster.ip_address
  value = "${var.project_id}/${var.region}/${var.cluster_id}/${var.instance_id}"
}
