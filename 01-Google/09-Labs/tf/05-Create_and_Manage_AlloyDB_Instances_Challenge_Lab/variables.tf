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

variable "instance_id" {
  description = "The ID of the existing AlloyDB instance."
  type        = string
}

variable "read_pool_instance_id" {
  description = "The ID of the read pool AlloyDB instance."
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

variable "admin_user" {
  description = "The admin user for AlloyDB."
  type        = map(any)
  default = {
    user     = null
    password = "your-password"
  }
}

variable "primary_instance" {
  description = "Primary cluster configuration that supports read and write operations."
  type = object({
    instance_id        = string,
    display_name       = optional(string),
    database_flags     = optional(map(string))
    labels             = optional(map(string))
    annotations        = optional(map(string))
    gce_zone           = optional(string)
    availability_type  = optional(string)
    machine_cpu_count  = optional(number, 2)
    ssl_mode           = optional(string)
    require_connectors = optional(bool)
    query_insights_config = optional(object({
      query_string_length     = optional(number)
      record_application_tags = optional(bool)
      record_client_address   = optional(bool)
      query_plans_per_minute  = optional(number)
    }))
    enable_public_ip = optional(bool, false)
    cidr_range       = optional(list(string))
  })
}

/*
variable "read_pool_instance" {
  description = "Primary cluster configuration that supports read and write operations."
  type = list(object({
    instance_id        = string
    display_name       = string
    node_count         = optional(number, 1)
    database_flags     = optional(map(string))
    availability_type  = optional(string)
    gce_zone           = optional(string)
    machine_cpu_count  = optional(number, 2)
    ssl_mode           = optional(string)
    require_connectors = optional(bool)
    query_insights_config = optional(object({
      query_string_length     = optional(number)
      record_application_tags = optional(bool)
      record_client_address   = optional(bool)
      query_plans_per_minute  = optional(number)
    }))
    enable_public_ip = optional(bool, false)
    cidr_range       = optional(list(string))
  }))
}

*/