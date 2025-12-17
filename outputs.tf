output "aggregate_id" {
  description = "ID of the created host aggregate"
  value       = openstack_compute_aggregate_v2.overcommit.id
}

output "aggregate_name" {
  description = "Name of the created host aggregate"
  value       = openstack_compute_aggregate_v2.overcommit.name
}

output "project_ids" {
  description = "IDs of the created projects"
  value       = { for idx, proj in openstack_identity_project_v3.sqa_pipeline : var.project_suffixes[idx] => proj.id }
}

output "project_names" {
  description = "Names of the created projects"
  value       = [for proj in openstack_identity_project_v3.sqa_pipeline : proj.name]
}

output "user_ids" {
  description = "IDs of the created users"
  value       = { for idx, user in openstack_identity_user_v3.sqa_users : var.project_suffixes[idx] => user.id }
}

output "user_names" {
  description = "Names of the created users"
  value       = [for user in openstack_identity_user_v3.sqa_users : user.name]
}

output "network_ids" {
  description = "IDs of the created networks"
  value       = { for idx, net in openstack_networking_network_v2.sqa_network : var.project_suffixes[idx] => net.id }
}

output "subnet_ids" {
  description = "IDs of the created subnets"
  value       = { for idx, subnet in openstack_networking_subnet_v2.sqa_subnet : var.project_suffixes[idx] => subnet.id }
}

output "router_ids" {
  description = "IDs of the created routers"
  value       = { for idx, router in openstack_networking_router_v2.sqa_router : var.project_suffixes[idx] => router.id }
}
