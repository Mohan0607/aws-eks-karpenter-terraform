locals {
  # profile="front_office_tf"
  default_tags = {
    Environment   = title(var.project_environment)
    CreatedBy     = "Terraform"
    Terraform     = "True"
    Department    = "Engineering"
    Administrator = title(var.project_resource_administrator)
    Project       = title(var.project_name)
  }
}



provider "aws" {

  region  = var.region
  profile = var.local_aws_profile_name
  default_tags {
    tags = local.default_tags
  }
}

terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.6"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.20"
    }
  }
}
