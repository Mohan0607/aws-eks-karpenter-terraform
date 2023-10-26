
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
variable "ecs_service_enable" {
  description = "Enable or disable the creation of ECS resources"
  type        = bool
  default     = false
}
variable "eks_service_enable" {
  description = "Enable or disable the creation of EKS resources"
  type        = bool
  default     = false
}

# Network Related VPC, Subnets and Security Groups
variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for VPC"
}
variable "bastion_subnets_cidr_list" {
  type        = list(any)
  description = "CIDR block list for bastion subnets"
  default     = []
}
variable "private_egress_subnets_cidr_list" {
  type        = list(any)
  description = "CIDR block list for private subnets with internet access"
  default     = []
}
variable "private_subnets_cidr_list" {
  type        = list(any)
  description = "CIDR block list for private subnets"
  default     = []
}

# Eks Cluster & Worker node
variable "cluster_version" {
  type        = string
  default     = "1.27"
  description = "EKS cluster version"
}

variable "public_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "capacity_type" {
  type        = string
  description = "EC2 Instance type [ON_DEMAND, SPOT]"
  default     = "ON_DEMAND"
}

variable "instance_types" {
  type        = list(string)
  description = "EC2 Instance types [example: t3.small, t3.medium]"
  default     = ["t3.medium"]
}
variable "scaling_config" {
  description = "EC2 Configuration for scaling"
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
  default = {
    desired_size = 2
    max_size     = 10
    min_size     = 2
  }
}

# Karpenter
variable "karpenter_helm_chart_version" {
  default = "v0.13.1"
  type    = string
}

# Fluent Bit
variable "fluentbit_helm_chart_version" {
  default = "0.1.21"
  type    = string
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