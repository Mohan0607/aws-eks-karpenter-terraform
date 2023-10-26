# Project
local_aws_profile_name = "front_office_tf"
region                 = "us-west-1"

# Env
stage_name                   = "prd"
app_env                      = "prd"
resource_name_prefix         = "front-prd"
project_name_resource_prefix = "front"

# Tags
project_resource_administrator = "Avinash Manjunath"
project_name                   = "Front Office"
project_environment            = "Production"

# Network
vpc_cidr_block                   = "172.35.0.0/16"
bastion_subnets_cidr_list        = ["172.35.0.0/24", "172.35.1.0/24"]
private_egress_subnets_cidr_list = ["172.35.2.0/24", "172.35.3.0/24"]
private_subnets_cidr_list        = ["172.35.4.0/24", "172.35.5.0/24"]

# DNS
load_balancer_domain_name = "api-frontoffice.dentalxchange.com"
api_gw_domain_name        = "api2-frontoffice.dentalxchange.com"
portal_cf_aliases = [
  "frontoffice.dentalxchange.com"
]
portal_domain_name     = "frontoffice.dentalxchange.com"
cloufront_acm_cert_arn = "arn:aws:acm:us-east-1:791768447655:certificate/e5593d44-530a-4f40-8a26-5d4098b5a7df"
API_acm_cert_arn       = "arn:aws:acm:us-west-1:791768447655:certificate/c6541320-b0b1-44f1-8da6-2608abdbdf75"

# ECS
front_api_ecs_cluster_name = "api-cluster"

# Eligibility Scheduler
eligibility_scheduler_service_name          = "eligibility-scheduler"
eligibility_scheduler_task_cpu              = 1024
eligibility_scheduler_task_memory           = 2048
eligibility_scheduler_container_cpu         = 1024
eligibility_scheduler_container_memory      = 2048
eligibility_scheduler_service_desired_count = 1
eligibility_scheduler_image                 = "791768447655.dkr.ecr.us-west-1.amazonaws.com/front-api/prd:eligibility-scheduler-282"

# Eligibility Normaliser
eligibility_normaliser_service_name          = "eligibility-normaliser"
eligibility_normaliser_task_cpu              = 1024
eligibility_normaliser_task_memory           = 2048
eligibility_normaliser_container_cpu         = 1024
eligibility_normaliser_container_memory      = 2048
eligibility_normaliser_service_desired_count = 1
eligibility_normaliser_image                 = "791768447655.dkr.ecr.us-west-1.amazonaws.com/front-api/prd:eligibility-normaliser-282"

# Eligibility Cleanup Worker
eligibility_cleanup_worker_service_name          = "eligibility-cleanup-worker"
eligibility_cleanup_worker_task_cpu              = 1024
eligibility_cleanup_worker_task_memory           = 2048
eligibility_cleanup_worker_container_cpu         = 1024
eligibility_cleanup_worker_container_memory      = 2048
eligibility_cleanup_worker_service_desired_count = 1
eligibility_cleanup_worker_image                 = "791768447655.dkr.ecr.us-west-1.amazonaws.com/front-api/prd:eligibility-cleanup-worker-282"

# Eligibility Worker
eligibility_worker_service_name          = "eligibility-worker"
eligibility_worker_task_cpu              = 1024
eligibility_worker_task_memory           = 2048
eligibility_worker_container_cpu         = 1024
eligibility_worker_container_memory      = 2048
eligibility_worker_service_desired_count = 1
eligibility_worker_image                 = "791768447655.dkr.ecr.us-west-1.amazonaws.com/front-api/prd:eligibilityworker-282"

# Eligibility API
eligibility_api_service_name          = "eligibility-api"
eligibility_api_task_cpu              = 1024
eligibility_api_task_memory           = 2048
eligibility_api_container_cpu         = 1024
eligibility_api_container_memory      = 2048
eligibility_api_service_desired_count = 1
eligibility_api_image                 = "791768447655.dkr.ecr.us-west-1.amazonaws.com/front-api/prd:eligibilityapi-282"

# External API
external_api_service_name          = "external-api"
external_api_task_cpu              = 1024
external_api_task_memory           = 2048
external_api_container_cpu         = 1024
external_api_container_memory      = 2048
external_api_service_desired_count = 1
external_api_image                 = "791768447655.dkr.ecr.us-west-1.amazonaws.com/front-api/prd:externalapi-282"

# External API
admin_api_service_name          = "admin-api"
admin_api_task_cpu              = 1024
admin_api_task_memory           = 2048
admin_api_container_cpu         = 1024
admin_api_container_memory      = 2048
admin_api_service_desired_count = 1
admin_api_image                 = "791768447655.dkr.ecr.us-west-1.amazonaws.com/front-api/prd:externalapi-282"

# Appointment Sync Worker
appt_sync_worker_service_name          = "appointment-sync-worker"
appt_sync_worker_task_cpu              = 1024
appt_sync_worker_task_memory           = 2048
appt_sync_worker_container_cpu         = 1024
appt_sync_worker_container_memory      = 2048
appt_sync_worker_service_desired_count = 1
appt_sync_worker_image                 = "791768447655.dkr.ecr.us-west-1.amazonaws.com/front-api/prd:appointmentsyncworker-282"

# Fluent Bit
fluent_bit_container_name        = "Firelens"
fluent_bit_container_cpu         = 0
fluent_bit_container_memory      = 2048
fluent_bit_service_desired_count = 1
fluent_bit_image                 = "public.ecr.aws/aws-observability/aws-for-fluent-bit:init-latest"

# RDS
api_db_database_name                   = "frontoffice"
api_db_master_username                 = "postgres"
api_db_instance_type                   = "db.r5.large"
api_db_instance_count                  = 1
api_db_rds_encryption                  = true
api_db_backup_window                   = "12:00-12:30"
serverless_rds_writer_instance_min_acu = 2
serverless_rds_writer_instance_max_acu = 32

# API GW
sso_authorizer_uri = "https://auth.dentalxchange.com/"

payer_match_url         = "https://prelive2.dentalxchange.com/dws/rest/DwsService/getPayerMatch"
eligibility_window_days = 2

#EKS
ecs_service_enable = true
eks_service_enable = false

capacity_type  = "ON_DEMAND"
instance_types = ["t3.medium"]

scaling_config = {
  desired_size = 3
  max_size     = 10
  min_size     = 3
}

# Karpenter
karpenter_helm_chart_version = "v0.13.1"

# Fluent Bit
fluentbit_helm_chart_version = "0.1.21"

# ALB Controller
alb_controller_helm_chart_version = "1.5.3"