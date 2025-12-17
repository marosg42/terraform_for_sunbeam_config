variable "aggregate_hosts" {
  description = "List of hosts to add to the aggregate"
  type        = list(string)
  default     = []
}

variable "aggregate_name" {
  description = "Name of the host aggregate"
  type        = string
  default     = "overcommit-aggregate"
}

variable "project_suffixes" {
  description = "Suffixes for the project names"
  type        = list(string)
  default     = ["1", "2", "3", "4"]
}

variable "user_password" {
  description = "Default password for created users"
  type        = string
  sensitive   = true
}

variable "network_cidr" {
  description = "CIDR block for project networks (e.g., 192.168.1.0/24)"
  type        = string
  default     = "192.168.1.0/24"
}

variable "external_network_name" {
  description = "Name of the external network for router gateway"
  type        = string
  default     = "external-network"
}

variable "quota_vcpus" {
  description = "Number of vCPUs quota for each project"
  type        = number
  default     = 64
}

variable "quota_instances" {
  description = "Number of instances quota for each project"
  type        = number
  default     = 20
}

variable "quota_ram" {
  description = "RAM quota in MB for each project"
  type        = number
  default     = 150000
}

variable "quota_security_groups" {
  description = "Number of security groups quota for each project"
  type        = number
  default     = 100
}

variable "quota_volumes" {
  description = "Number of volumes quota for each project"
  type        = number
  default     = 10
}

variable "flavors_to_delete" {
  description = "List of flavor names to delete"
  type        = list(string)
  default     = [
    "m1.tiny-sev",
    "m1.medium",
    "m1.tiny",
    "m1.small-sev",
    "m1.small",
    "m1.medium-sev",
    "m1.large",
    "m1.large-sev"
  ]
}
