/*
output "read_pool_instances" {
  value = google_alloydb_instance.read_pool_instances
}

*/

output "read_pool_instances" {
  description = "Read Pool instance IDs"
  value       = module.alloy-db.read_instance_ids
}


output "primary_instance_private_ip_address" {
  description = "primary instance public IP"
  value = module.alloy-db.primary_instance.ip_address
}
