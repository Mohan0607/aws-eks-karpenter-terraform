# locals {
#   alb_contoller_name_prefix = join("-", [var.resource_name_prefix, "alb-contoller"])

#   alb_contoller_namespace           = "kube-system"
#   helm_alb_release_name             = join("-", [var.resource_name_prefix, "alb-contoller"])
#   helm_alb_contoller_chart          = "aws-load-balancer-controller"
#   alb_controller_helm_chart_version = var.alb_controller_helm_chart_version
# }

# provider "helm" {
#   alias = "alb"

#   kubernetes {
#     host = length(aws_eks_cluster.cluster) > 0 ? aws_eks_cluster.cluster[0].endpoint : null

#     cluster_ca_certificate = local.eks_cluster_exists ? base64decode(aws_eks_cluster.cluster[0].certificate_authority[0].data) : null
#     token                  = length(data.aws_eks_cluster_auth.cluster) > 0 ? data.aws_eks_cluster_auth.cluster[0].token : null
#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       args        = ["eks", "get-token", "--cluster-name", length(aws_eks_cluster.cluster) > 0 ? aws_eks_cluster.cluster[0].id : "", "--profile", var.local_aws_profile_name]
#       command     = "aws"
#     }
#   }
# }

# provider "kubectl" {
#   alias = "alb"

#   apply_retry_count = 5
#   host              = length(aws_eks_cluster.cluster) > 0 ? aws_eks_cluster.cluster[0].endpoint : null

#   cluster_ca_certificate = local.eks_cluster_exists ? base64decode(aws_eks_cluster.cluster[0].certificate_authority[0].data) : null
#   token                  = length(data.aws_eks_cluster_auth.cluster) > 0 ? data.aws_eks_cluster_auth.cluster[0].token : null
#   load_config_file       = false
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args        = ["eks", "get-token", "--cluster-name", length(aws_eks_cluster.cluster) > 0 ? aws_eks_cluster.cluster[0].id : "", "--profile", var.local_aws_profile_name]
#   }
# }
# provider "kubernetes" {
#   alias = "alb"
#   host  = length(aws_eks_cluster.cluster) > 0 ? aws_eks_cluster.cluster[0].endpoint : null

#   cluster_ca_certificate = local.eks_cluster_exists ? base64decode(aws_eks_cluster.cluster[0].certificate_authority[0].data) : null
#   token                  = length(data.aws_eks_cluster_auth.cluster) > 0 ? data.aws_eks_cluster_auth.cluster[0].token : null
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args        = ["eks", "get-token", "--cluster-name", length(aws_eks_cluster.cluster) > 0 ? aws_eks_cluster.cluster[0].id : "", "--profile", var.local_aws_profile_name]

#   }
# }
# # Alb Controller

# resource "kubernetes_service_account" "service_account" {
#   count    = local.enable_eks_service
#   provider = kubernetes.alb
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"
#     labels = {
#       "app.kubernetes.io/name"      = "aws-load-balancer-controller"
#       "app.kubernetes.io/component" = "controller"
#     }
#     annotations = {
#       "eks.amazonaws.com/role-arn"               = aws_iam_role.kubernetes_alb_controller[0].arn
#       "eks.amazonaws.com/sts-regional-endpoints" = "true"
#     }
#   }
#   depends_on = [aws_eks_cluster.cluster]
# }

# resource "helm_release" "alb-controller" {
#   count      = local.enable_eks_service
#   provider   = helm.alb
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
#     value = aws_vpc.main.id
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
#     value = aws_eks_cluster.cluster[0].name
#   }

#   depends_on = [aws_eks_cluster.cluster, kubernetes_service_account.service_account]
# }