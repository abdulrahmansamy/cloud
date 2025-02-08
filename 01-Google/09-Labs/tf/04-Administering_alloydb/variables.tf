variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "region" {
  description = "The region for the AlloyDB cluster."
  type        = string
  default     = "us-central1"
}

variable "cluster_id" {
  description = "The ID of the existing AlloyDB cluster."
  type        = string
}

variable "network_name" {
  description = "The name of the network in which to provision resources."
  type        = string
  default     = "default"
}

variable "read_pool_instance_count" {
  description = "Number of read pool instances."
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "The machine type for the read pool instances."
  type        = string
  default     = "db-custom-4-32768"
}
