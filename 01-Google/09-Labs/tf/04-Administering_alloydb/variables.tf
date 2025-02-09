variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "region" {
  description = "The region for the AlloyDB cluster."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zone where AlloyDb cluster will be deployed"
  type        = string
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

variable "read_pool_instance_node_count" {
  description = "number of nodes in a read pool instance."
  type        = number
  default     = 2
}
variable "cpu_count" {
  description = "The machine type for the read pool instances."
  type        = number
  default     = 2
}

variable "backup_id" {
  description = "Unique ID for the backup"
  type        = string
}
