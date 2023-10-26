
# Karpenter
karpenter_helm_chart_version = "v0.31.0"

instance_sizes    = ["nano", "micro", "small", "large", "xlarge", "2xlarge"]
instance_families = ["c5", "m5", "r5"]

# ALB Controller
alb_controller_helm_chart_version = "1.5.3"

# CSI Driver
rotation_poll_interval_time = "500s"