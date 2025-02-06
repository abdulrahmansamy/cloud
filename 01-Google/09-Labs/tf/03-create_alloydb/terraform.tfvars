project_id   = "qwiklabs-gcp-00-ec1cfffd0454"
region       = "us-west1"
zone         = "us-west1-a"
network_name = "peering-network"

/*
cluster_id   = "lab-cluster"
primary_instance = {
  instance_id = "lab-instance"
  machine_cpu_count = 2
}
*/
admin_user = {
  user     = null
  password = "Change3Me"
}


clusters_list = [
  {
    cluster_id = "lab-cluster"
    primary_instance = {
      instance_id       = "lab-instance"
      machine_cpu_count = 2
    }
  },
  {
    cluster_id = "gcloud-lab-cluster"
    primary_instance = {
      instance_id       = "gcloud-lab-instance"
      machine_cpu_count = 2
    }
  }
]
