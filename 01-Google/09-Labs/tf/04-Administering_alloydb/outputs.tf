output "read_pool_instances" {
  value = google_alloydb_instance.read_pool_instances
}



output "primary_instance_private_ip_address" {
  description = "primary instance public IP"
  value       = google_alloydb_instance.ip_address
}

