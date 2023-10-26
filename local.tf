locals {
  enable_ecs_service = var.ecs_service_enable ? 1 : 0
  enable_eks_service = var.eks_service_enable ? 1 : 0

  # CSI driver
  csi_driver_name_prefix = join("-", [var.resource_name_prefix, "csi-driver"])
  csi_driver_namespace   = "kube-system"

  # Karpenter
  karpenter_namespace         = "karpenter"
  helm_karpenter_release_name = join("-", [var.resource_name_prefix, "karpenter"])

  #ALB 
  alb_contoller_name_prefix = join("-", [var.resource_name_prefix, "alb-contoller"])
  alb_contoller_namespace   = "kube-system"
}