
variable "local_aws_profile_name" {
  type        = string
  description = "AWS Profile name used in local machine"
  default     = "default"
}

# Project Configurations and Name Conventions
variable "region" {
  type        = string
  description = "Project Region"
  default     = "us-west-1"
}

variable "resource_name_prefix" {
  type        = string
  description = "Resource name prefix"
}
variable "stage_name" {
  type        = string
  description = "Stage name"
}
variable "app_env" {
  type        = string
  description = "Application Environment"
}

variable "project_environment" {
  type        = string
  description = "Project Environment"
}
variable "project_resource_administrator" {
  type        = string
  description = "Project Resource Administrator"
  default     = "Avinash Manjunath"
}
variable "project_name" {
  type        = string
  description = "Project name"
}
variable "project_name_resource_prefix" {
  type        = string
  description = "Project name for the use in resource naming"
}


# Karpenter
variable "karpenter_helm_chart_version" {
  default = "v0.13.1"
  type    = string
}

variable "instance_type" {
  type    = list(string)
  default = ["m6a.large", "m6a.large"]
}

# ALB Controller
variable "alb_controller_helm_chart_version" {
  type        = string
  default     = "1.5.3"
  description = "ALB Controller Helm chart version."
}

variable "settings" {
  default     = {}
  description = "Additional settings which will be passed to the Helm chart values."
}

#CSI driver

variable "rotation_poll_interval_time" {
  type        = string
  default     = "300s"
  description = "The secrets fetching interval time"
}