# Project
local_aws_profile_name = "853973692277_limited-admin"
region                 = "us-east-1"

# Env
stage_name                   = "dev"
app_env                      = "dev"
resource_name_prefix         = "front-dev"
project_name_resource_prefix = "front"

ecs_service_enable = true
eks_service_enable = true

# Tags
project_resource_administrator = "Avinash Manjunath"
project_name                   = "Front Office"
project_environment            = "development"

# Network
vpc_cidr_block                   = "172.32.0.0/16"
bastion_subnets_cidr_list        = ["172.32.0.0/24", "172.32.1.0/24"]
private_egress_subnets_cidr_list = ["172.32.2.0/24", "172.32.3.0/24"]
private_subnets_cidr_list        = ["172.32.4.0/24", "172.32.5.0/24"]

#EKS
cluster_version = "1.27"
public_access_cidrs = ["0.0.0.0/0"]
capacity_type  = "ON_DEMAND"
instance_types = ["t3.medium"]

scaling_config = {
  desired_size = 2
  max_size     = 10
  min_size     = 2
}
