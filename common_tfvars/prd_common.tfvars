# Common variables that are shared by both the infrastructure deployment and the app deployment

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