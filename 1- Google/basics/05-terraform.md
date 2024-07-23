
```
terraform -version
```
```
mkdir tfinfra && cd $_
```
```
touch provider.tf edit $_
```
```
  provider "google" {
  project = "qwiklabs-gcp-01-093294853782"
  region  = "europe-west4"
  zone    = "europe-west4-b"
}
```
```
terraform init
```
```
touch instance.tf edit $_
```
```
resource google_compute_instance "vm_instance" {
name         = "${var.instance_name}"
zone         = "${var.instance_zone}"
machine_type = "${var.instance_type}"
boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      }
  }
 network_interface {
    network = "default"
    access_config {
      # Allocate a one-to-one NAT IP to the instance
      nat_ip = google_compute_address.vm_static_ip.address
    }
  }
}

resource "google_compute_address" "vm_static_ip" {
  name = "terraform-static-ip"
}
```
```
touch  variables.tf edit $_
```
```
variable "instance_name" {
  type        = string
  description = "Name for the Google Compute instance"
}
variable "instance_zone" {
  type        = string
  description = "Zone for the Google Compute instance"
}
variable "instance_type" {
  type        = string
  description = "Disk type of the Google Compute instance"
  default     = "e2-medium"
}

variable "bucket_name" {
  type        = string
  description = "A Unique name for the Google Bucket"
  default     = "qwiklabs-gcp-01-093294853782"
}
```
```
touch outputs.tf edit $_ 
```
```
output "network_IP" {
  value = google_compute_instance.vm_instance.instance_id
  description = "The internal ip address of the instance"
}
output "instance_link" {
  value = google_compute_instance.vm_instance.self_link
  description = "The URI of the created resource."
}
```

```
 terraform plan --var "instance_name=myinstance" --var "instance_zone=europe-west4-b"
 ```

 ```
terraform apply --auto-approve --var "instance_name=myinstance" --var "instance_zone=europe-west4-b"
 ```
```
 touch exp.tf && edit $_
```

```
# Create a new instance that uses the bucket
resource "google_compute_instance" "another_instance" {

  name         = "terraform-instance-2"
  machine_type = "e2-micro"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "default"
    access_config {
    }
  }
  # Tells Terraform that this VM instance must be created only after the
  # storage bucket has been created.
  depends_on = [google_storage_bucket.example_bucket]
}

# New resource for the storage bucket our application will use.
resource "google_storage_bucket" "example_bucket" {
  name     = var.bucket_name
  location = "US"
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}
```

```
terraform apply --auto-approve --var "instance_name=myinstance" --var "instance_zone=europe-west4-b"
```

### View Dependency Graph
```
terraform graph | dot -Tsvg > graph.svg
```

```
gsutil cp graph.svc gs://bucket
```