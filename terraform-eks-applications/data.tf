data "aws_vpc" "frontoffice" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}

output "vpc_id" {
  description = "The VPC ID"
  value       = data.aws_vpc.frontoffice.id
}

data "aws_eks_cluster" "cluster" {
  name = local.eks_cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.eks_cluster_name
}


# data "aws_iam_role" "kubernetes_alb_controller" {
#   name = local.alb_controller_role_name
# }

data "aws_iam_role" "karpenter_controller" {
  name = local.karpenter_controller_name
}

data "aws_iam_instance_profile" "karpenter_instance" {
  name = local.karpenter_instance_name
}
