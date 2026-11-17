# Terraform to configure deployed Sunbeam

This Terraform configuration creates OpenStack infrastructure for our pipeline testing.

## Resources Created

1. **Host Aggregate** with overcommit ratios:
   - CPU allocation ratio: 4.0
   - RAM allocation ratio: 1.0 (no overcommit)
   - Disk allocation ratio: 1.0

2. **4 Projects** named `sqa-pipeline-1` through `sqa-pipeline-4`

3. **4 Users** (one per project) named `sqa-user-1` through `sqa-user-4` with admin and load-balancer_member roles

4. **Networking per project**:
   - Network (one per project)
   - Subnet with /24 CIDR (same CIDR for all projects)
   - Router connected to external network
   - Router interface connecting subnet to router

5. **Quotas per project**:
   - vCPUs: 64 (configurable)
   - Instances: 20 (configurable)
   - RAM: 150000 MB (configurable)
   - Security Groups: 100 (configurable)
   - Volumes: 10 (configurable)

6. **Compute Flavors**:
   - `cpu2-ram4-disk50`: 2 vCPUs, 4GB RAM, 50GB disk
   - `cpu2-ram4-disk16`: 2 vCPUs, 4GB RAM, 16GB disk
   - `cpu2-ram8-disk16`: 2 vCPUs, 8GB RAM, 16GB disk
   - `cpu2-ram8-disk20`: 2 vCPUs, 8GB RAM, 20GB disk
   - `cpu4-ram16-disk50`: 4 vCPUs, 16GB RAM, 50GB disk
   - `juju_cpu2_ram3andhalf_disk30`: 2 vCPUs, 3.5GB RAM, 30GB disk

## Prerequisites

- OpenStack credentials configured (via environment variables or clouds.yaml)
- Terraform >= 1.0
- OpenStack provider >= 3.4.0

## Usage

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your values:
   - `aggregate_hosts`: List of compute hosts to add to the aggregate
   - `aggregate_name`: Name for the host aggregate (optional)
   - `project_suffixes`: Suffixes for project names (optional)
   - `user_password`: Password for the created users
   - Quota settings (all optional, with sensible defaults)

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Plan the deployment:
   ```bash
   terraform plan
   ```

5. Apply the configuration:
   ```bash
   terraform apply
   ```

## Variables

- `aggregate_hosts` (required): List of hosts to include in the aggregate
- `aggregate_name` (optional): Name of the host aggregate (default: "overcommit-aggregate")
- `project_suffixes` (optional): List of suffixes for project names (default: ["1", "2", "3", "4"])
- `user_password` (required): Password for created users (sensitive)
- `network_cidr` (optional): CIDR block for project networks (default: "192.168.1.0/24")
- `external_network_name` (optional): Name of the external network (default: "external-network")
- `quota_vcpus` (optional): Number of vCPUs quota per project (default: 64)
- `quota_instances` (optional): Number of instances quota per project (default: 20)
- `quota_ram` (optional): RAM quota in MB per project (default: 150000)
- `quota_security_groups` (optional): Number of security groups quota per project (default: 100)
- `quota_volumes` (optional): Number of volumes quota per project (default: 10)
- `flavors_to_delete` (optional): List of flavor names to delete (default: legacy m1.* flavors)

## Outputs

- `aggregate_id`: ID of the created host aggregate
- `aggregate_name`: Name of the host aggregate
- `project_ids`: Map of project suffixes to project IDs
- `project_names`: List of created project names
- `user_ids`: Map of user suffixes to user IDs
- `user_names`: List of created user names
- `network_ids`: Map of project suffixes to network IDs
- `subnet_ids`: Map of project suffixes to subnet IDs
- `router_ids`: Map of project suffixes to router IDs

## Notes

- Users are assigned the **admin** role (not member) in their respective projects for full control
- All flavors are created as public and available to all projects
- The same CIDR block is used for all project subnets (isolated at the project level)
