project_id   = "qwiklabs-gcp-02-419a741a6697"
region       = "us-east4"
zone         = "us-east4-c"
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
