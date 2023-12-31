# Project
local_aws_profile_name = "853973692277_limited-admin"
region                 = "us-east-1"

# Karpenter
karpenter_helm_chart_version = "v0.16.3"
instance_type = ["t3.large", "t3.medium", "m5.large"]

# ALB Controller
alb_controller_helm_chart_version = "1.5.3"

# CSI Driver
rotation_poll_interval_time = "500s"