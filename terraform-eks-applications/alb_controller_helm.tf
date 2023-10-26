# locals {
#   alb_contoller_name_prefix = join("-", [var.resource_name_prefix, "alb-contoller"])

#   alb_contoller_namespace           = "kube-system"
#   helm_alb_release_name             = join("-", [var.resource_name_prefix, "alb-contoller"])
#   helm_alb_contoller_chart          = "aws-load-balancer-controller"
#   alb_controller_helm_chart_version = var.alb_controller_helm_chart_version
# }

# # Alb Controller

# resource "kubernetes_service_account" "service_account" {
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"
#     labels = {
#       "app.kubernetes.io/name"      = "aws-load-balancer-controller"
#       "app.kubernetes.io/component" = "controller"
#     }
#     annotations = {
#       "eks.amazonaws.com/role-arn"               = data.aws_iam_role.kubernetes_alb_controller.arn
#       "eks.amazonaws.com/sts-regional-endpoints" = "true"
#     }
#   }
#   depends_on = [data.aws_eks_cluster.cluster]
# }

# resource "helm_release" "alb-controller" {
#   name       = local.helm_alb_release_name
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = local.alb_contoller_namespace
#   set {
#     name  = "region"
#     value = var.region
#   }

#   set {
#     name  = "vpcId"
#     value = data.aws_vpc.frontoffice.id
#   }

#   set {
#     name  = "image.repository"
#     value = "602401143452.dkr.ecr.${var.region}.amazonaws.com/amazon/aws-load-balancer-controller"
#   }

#   set {
#     name  = "serviceAccount.create"
#     value = "false"
#   }

#   set {
#     name  = "serviceAccount.name"
#     value = "aws-load-balancer-controller"
#   }

#   set {
#     name  = "clusterName"
#     value = data.aws_eks_cluster.cluster.name
#   }

#   depends_on = [data.aws_eks_cluster.cluster, kubernetes_service_account.service_account]
# }