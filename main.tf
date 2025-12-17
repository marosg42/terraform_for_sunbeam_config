terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.4.0"
    }
  }
}

provider "openstack" {}

# Create host aggregate with overcommit settings
resource "openstack_compute_aggregate_v2" "overcommit" {
  name  = var.aggregate_name
  hosts = var.aggregate_hosts

  metadata = {
    cpu_allocation_ratio    = "4.0"
    ram_allocation_ratio    = "1.0"
    disk_allocation_ratio   = "1.0"
  }
}

# Create projects
resource "openstack_identity_project_v3" "sqa_pipeline" {
  count       = length(var.project_suffixes)
  name        = "sqa-pipeline-${var.project_suffixes[count.index]}"
  description = "SQA Pipeline project ${var.project_suffixes[count.index]}"
}

# Create users for each project
resource "openstack_identity_user_v3" "sqa_users" {
  count              = length(var.project_suffixes)
  name               = "sqa-user-${var.project_suffixes[count.index]}"
  default_project_id = openstack_identity_project_v3.sqa_pipeline[count.index].id
  password           = var.user_password
  description        = "User for sqa-pipeline-${var.project_suffixes[count.index]}"
}

# Assign admin role to users in their respective projects
resource "openstack_identity_role_assignment_v3" "sqa_user_role" {
  count      = length(var.project_suffixes)
  user_id    = openstack_identity_user_v3.sqa_users[count.index].id
  project_id = openstack_identity_project_v3.sqa_pipeline[count.index].id
  role_id    = data.openstack_identity_role_v3.admin.id
}

# Get the load-balancer_member role
data "openstack_identity_role_v3" "load_balancer_member" {
  name = "load-balancer_member"
}

# Assign load-balancer_member role to all sqa-user* in their projects
resource "openstack_identity_role_assignment_v3" "sqa_user_lb_role" {
  count      = length(var.project_suffixes)
  user_id    = openstack_identity_user_v3.sqa_users[count.index].id
  project_id = openstack_identity_project_v3.sqa_pipeline[count.index].id
  role_id    = data.openstack_identity_role_v3.load_balancer_member.id
}

# Get the admin role
data "openstack_identity_role_v3" "admin" {
  name = "admin"
}

# Get the member role (kept for reference)
data "openstack_identity_role_v3" "member" {
  name = "member"
}

# Get the external network
data "openstack_networking_network_v2" "external" {
  name = var.external_network_name
}

# Create networks for each project
resource "openstack_networking_network_v2" "sqa_network" {
  count          = length(var.project_suffixes)
  name           = "sqa-network-${var.project_suffixes[count.index]}"
  admin_state_up = true
  tenant_id      = openstack_identity_project_v3.sqa_pipeline[count.index].id
}

# Create subnets for each network
resource "openstack_networking_subnet_v2" "sqa_subnet" {
  count           = length(var.project_suffixes)
  name            = "sqa-subnet-${var.project_suffixes[count.index]}"
  network_id      = openstack_networking_network_v2.sqa_network[count.index].id
  cidr            = var.network_cidr
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
  tenant_id       = openstack_identity_project_v3.sqa_pipeline[count.index].id
}

# Create routers for each project
resource "openstack_networking_router_v2" "sqa_router" {
  count               = length(var.project_suffixes)
  name                = "sqa-router-${var.project_suffixes[count.index]}"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external.id
  tenant_id           = openstack_identity_project_v3.sqa_pipeline[count.index].id
}

# Attach subnets to routers
resource "openstack_networking_router_interface_v2" "sqa_router_interface" {
  count     = length(var.project_suffixes)
  router_id = openstack_networking_router_v2.sqa_router[count.index].id
  subnet_id = openstack_networking_subnet_v2.sqa_subnet[count.index].id
}

# Set compute quotas for each project
resource "openstack_compute_quotaset_v2" "sqa_quota" {
  count                = length(var.project_suffixes)
  project_id           = openstack_identity_project_v3.sqa_pipeline[count.index].id
  cores                = var.quota_vcpus
  instances            = var.quota_instances
  ram                  = var.quota_ram
}

# Set network quotas for each project
resource "openstack_networking_quota_v2" "sqa_network_quota" {
  count          = length(var.project_suffixes)
  project_id     = openstack_identity_project_v3.sqa_pipeline[count.index].id
  security_group = var.quota_security_groups
}

# Set block storage quotas for each project
resource "openstack_blockstorage_quotaset_v3" "sqa_volume_quota" {
  count      = length(var.project_suffixes)
  project_id = openstack_identity_project_v3.sqa_pipeline[count.index].id
  volumes    = var.quota_volumes
}

# Import and manage flavors for deletion
# These resources will be imported and then destroyed when removed from config
# COMMENTED OUT - Flavors already deleted
# resource "openstack_compute_flavor_v2" "flavors_to_delete" {
#   for_each = toset(var.flavors_to_delete)
#   
#   name  = each.value
#   ram   = 512  # Placeholder values - will be overridden by import
#   vcpus = 1
#   disk  = 1
#
#   lifecycle {
#     ignore_changes = [ram, vcpus, disk, swap, rx_tx_factor, is_public, ephemeral]
#   }
# }

# Create new flavors
resource "openstack_compute_flavor_v2" "cpu2_ram4_disk50" {
  name         = "cpu2-ram4-disk50"
  ram          = 4096
  vcpus        = 2
  disk         = 50
  is_public    = true
  rx_tx_factor = 1.0
}

resource "openstack_compute_flavor_v2" "cpu2_ram4_disk16" {
  name         = "cpu2-ram4-disk16"
  ram          = 4096
  vcpus        = 2
  disk         = 16
  is_public    = true
  rx_tx_factor = 1.0
}

resource "openstack_compute_flavor_v2" "cpu2_ram8_disk20" {
  name         = "cpu2-ram8-disk20"
  ram          = 8192
  vcpus        = 2
  disk         = 20
  is_public    = true
  rx_tx_factor = 1.0
}

resource "openstack_compute_flavor_v2" "cpu4_ram16_disk50" {
  name         = "cpu4-ram16-disk60"
  ram          = 16384
  vcpus        = 4
  disk         = 50
  is_public    = true
  rx_tx_factor = 1.0
}

