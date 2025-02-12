# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "projects/qwiklabs-gcp-01-feff1ef577c1/locations/us-central1/clusters/lab-cluster/instances/lab-instance"
resource "google_alloydb_instance" "existing_cluster" {
  annotations       = {}
  availability_type = "REGIONAL"
  cluster           = "projects/qwiklabs-gcp-01-feff1ef577c1/locations/us-central1/clusters/lab-cluster"
  database_flags = {
    "alloydb.enable_pgaudit" = "on"
  }
  display_name  = null
  gce_zone      = null
  instance_id   = "lab-instance"
  instance_type = "PRIMARY"
  labels        = {}
  client_connection_config {
    require_connectors = false
    ssl_config {
      ssl_mode = "ENCRYPTED_ONLY"
    }
  }
  machine_config {
    cpu_count = 2
  }
  query_insights_config {
    query_plans_per_minute  = 5
    query_string_length     = 1024
    record_application_tags = false
    record_client_address   = false
  }
}
