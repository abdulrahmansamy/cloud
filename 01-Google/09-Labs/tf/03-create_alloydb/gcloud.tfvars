project_id   = "qwiklabs-gcp-01-cbe0452f2562"
region       = "us-east4"
zone         = "us-east4-a"
cluster_id   = "gcloud-lab-cluster"
network_name = "peering-network"
primary_instance = {
  instance_id       = "gcloud-lab-instance"
  machine_type      = "db-custom-4-32768"
  machine_cpu_count = 2
}
admin_user = {
  user     = "admin"
  password = "Change3Me"
}