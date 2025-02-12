
project_id                    = "qwiklabs-gcp-00-b6b2c2834513"
region                        = "us-west1"
zone                          = "us-west1-a"
network_name                  = "peering-network"
cluster_id                    = "lab-cluster"
instance_id                   = "lab-instance"
read_pool_instance_id         = "lab-instance-rp1"
read_pool_instance_count      = 1
read_pool_instance_node_count = 2
cpu_count                     = 2
backup_id                     = "lab-backup"
admin_user = {
  user     = null
  password = "Change3Me"
}

primary_instance = {
  instance_id       = "lab-instance"
  machine_cpu_count = 2
}