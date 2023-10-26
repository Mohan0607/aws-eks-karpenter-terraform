locals {
  vpc_name                  = join("-", [var.resource_name_prefix, "vpc"])
  eks_cluster_name          = join("-", [var.resource_name_prefix, "eks-cluster"])
  karpenter_controller_name = join("-", [var.resource_name_prefix, "karpenter-controllers-role"])
  karpenter_instance_name   = join("-", [var.resource_name_prefix, "karpenter-node-instance-profiles"])
  #alb_controller_role_name  = join("-", [local.alb_contoller_name_prefix, "role"])
}