# locals {
#   karpenter_namespace            = "karpenter"
#   karpenter_helm_chart_version   = var.karpenter_helm_chart_version
#   karpenter_service_account_name = join("-", [var.resource_name_prefix, "karpenter-sa"])

# }

# provider "helm" {
#   alias = "karpenter"

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
#   alias = "karpenter"

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
#   alias = "karpenter"
#   host  = length(aws_eks_cluster.cluster) > 0 ? aws_eks_cluster.cluster[0].endpoint : null

#   cluster_ca_certificate = local.eks_cluster_exists ? base64decode(aws_eks_cluster.cluster[0].certificate_authority[0].data) : null
#   token                  = length(data.aws_eks_cluster_auth.cluster) > 0 ? data.aws_eks_cluster_auth.cluster[0].token : null
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args        = ["eks", "get-token", "--cluster-name", length(aws_eks_cluster.cluster) > 0 ? aws_eks_cluster.cluster[0].id : "", "--profile", var.local_aws_profile_name]

#   }
# }
# # provider "helm" {
# #   kubernetes {
# #     host                   = aws_eks_cluster.cluster[0].endpoint
# #     cluster_ca_certificate = base64decode(aws_eks_cluster.cluster[0].certificate_authority[0].data)
# #     token                  = data.aws_eks_cluster_auth.cluster[0].token
# #     exec {
# #       api_version = "client.authentication.k8s.io/v1beta1"
# #       args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.cluster[0].id, "--profile", "853973692277_limited-admin"]
# #       command     = "aws"
# #     }
# #   }
# # }

# # provider "kubectl" {
# #   apply_retry_count      = 5
# #   host                   = aws_eks_cluster.cluster[0].endpoint
# #   cluster_ca_certificate = base64decode(aws_eks_cluster.cluster[0].certificate_authority[0].data)
# #   token                  = data.aws_eks_cluster_auth.cluster[0].token
# #   load_config_file       = false

# #   exec {
# #     api_version = "client.authentication.k8s.io/v1beta1"
# #     command     = "aws"
# #     # This requires the awscli to be installed locally where Terraform is executed
# #     args = ["eks", "get-token", "--cluster-name", aws_eks_cluster.cluster[0].id, "--profile", "853973692277_limited-admin"]
# #   }
# # }
# # Karpenter
# resource "helm_release" "karpenter" {
#   provider         = helm.karpenter
#   count            = local.enable_eks_service
#   namespace        = local.karpenter_namespace
#   create_namespace = true
#   name             = join("-", [var.resource_name_prefix, "karpenter"])
#   repository       = "https://charts.karpenter.sh"
#   chart            = "karpenter"
#   version          = local.karpenter_helm_chart_version

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.karpenter_controller[0].arn
#   }

#   set {
#     name  = "clusterName"
#     value = aws_eks_cluster.cluster[0].name
#   }

#   set {
#     name  = "clusterEndpoint"
#     value = aws_eks_cluster.cluster[0].endpoint
#   }

#   set {
#     name  = "aws.defaultInstanceProfile"
#     value = aws_iam_instance_profile.karpenter[0].name
#   }

#   depends_on = [aws_eks_cluster.cluster, aws_eks_node_group.nodes]
# }


# # Karpenter Provisioner
# resource "kubectl_manifest" "karpenter_awsnodetemplate" {
#   provider = kubectl.karpenter
#   count     = local.enable_eks_service
#   yaml_body = file("${path.module}/k8s/awstemplate.yaml")

#   depends_on = [
#     aws_eks_cluster.cluster,
#     helm_release.karpenter,
#   ]
# }

# resource "kubectl_manifest" "karpenter_provisioner" {
#   provider = kubectl.karpenter
#   count     = local.enable_eks_service
#   yaml_body = file("${path.module}/k8s/provisioner.yaml")

#   depends_on = [
#     aws_eks_cluster.cluster,
#     helm_release.karpenter,
#     kubectl_manifest.karpenter_awsnodetemplate
#   ]
# }



# # resource "kubectl_manifest" "karpenter_resources" {
# #   provider  = kubectl.karpenter
# #   count     = local.enable_eks_service

# #   yaml_body = <<-YAML
# #     apiVersion: karpenter.sh/v1alpha5
# #     kind: Provisioner
# #     metadata:
# #       name: default
# #     spec:
# #       providerRef:
# #         name: default
# #       ttlSecondsAfterEmpty: 30 # scale down nodes after 30 seconds without workloads (excluding daemons)
# #       ttlSecondsUntilExpired: 604800 # expire nodes after 7 days (in seconds) = 7 * 60 * 60 * 24
# #       limits:
# #         resources:
# #           cpu: 100 # limit to 100 CPU cores
# #       requirements:
# #         - key: karpenter.k8s.aws/instance-family
# #           operator: In
# #           values: [c5, m5, r5]
# #         - key: karpenter.k8s.aws/instance-size
# #           operator: In
# #           values: [nano, micro, small, large]
# #     ---
# #     apiVersion: karpenter.k8s.aws/v1alpha1
# #     kind: AWSNodeTemplate
# #     metadata:
# #       name: default
# #     spec:
# #       subnetSelector:
# #         kubernetes.io/cluster/${aws_eks_cluster.cluster[0].name}: owned
# #       securityGroupSelector:
# #         kubernetes.io/cluster/${aws_eks_cluster.cluster[0].name}: owned
# #   YAML

# #   depends_on = [
# #     aws_eks_cluster.cluster, helm_release.karpenter
# #   ]
# # }

# # resource "kubectl_manifest" "karpenter_provisioner" {
# #   provider  = kubectl.karpenter
# #   count     = local.enable_eks_service
# #   yaml_body = <<-YAML
# #     apiVersion: karpenter.sh/v1alpha5
# #     kind: Provisioner
# #     metadata:
# #       name: default
# #       namespace: karpenter
# #     spec:
# #       limits:
# #         resources:
# #           cpu: 1000
# #           memory: 1000
# #       provider:
# #         # apiVersion: extensions.karpenter.sh/v1alpha1
# #         # kind: AWS
# #         securityGroupSelector:
# #           kubernetes.io/cluster/${aws_eks_cluster.cluster[0].name}: owned
# #         subnetSelector:
# #           kubernetes.io/cluster/${aws_eks_cluster.cluster[0].name}: owned
# #         # instanceProfile: ${aws_iam_instance_profile.karpenter[0].name}
# #       requirements:
# #       - key: karpenter.k8s.aws/instance-family
# #         operator: In
# #         values: [c5, m5, r5, m6]
# #       - key: karpenter.k8s.aws/instance-size
# #         operator: In
# #         values: [nano, micro, small]
# #       ttlSecondsAfterEmpty: 30
# #   YAML

# #   depends_on = [
# #     aws_eks_cluster.cluster
# #   ]
# # }


# # resource "kubectl_manifest" "karpenter_provisioner" {
# #   provider  = kubectl.karpenter
# #   count     = local.enable_eks_service
# #   yaml_body = <<-YAML
# #     apiVersion: karpenter.sh/v1alpha5
# #     kind: Provisioner
# #     metadata:
# #       name: default
# #     spec:
# #       provider:
# #         type: aws
# #       ttlSecondsAfterEmpty: 30 # scale down nodes after 30 seconds without workloads (excluding daemons)
# #       ttlSecondsUntilExpired: 604800 # expire nodes after 7 days (in seconds) = 7 * 60 * 60 * 24
# #       limits:
# #         resources:
# #           cpu: 100 # limit to 100 CPU cores
# #       requirements:
# #         - key: karpenter.k8s.aws/instance-family
# #           operator: In
# #           values: [c5, m5, r5]
# #         - key: karpenter.k8s.aws/instance-size
# #           operator: In
# #            values: [nano, micro, small, large]
# #       providerRef:
# #         name: default
# #   YAML

# #   depends_on = [
# #     aws_eks_cluster.cluster, kubectl_manifest.karpenter_node_template, helm_release.karpenter
# #   ]
# # }

# # resource "kubectl_manifest" "karpenter_node_template" {
# #   provider  = kubectl.karpenter
# #   count     = local.enable_eks_service
# #   yaml_body = <<-YAML
# #     apiVersion: karpenter.k8s.aws/v1alpha1
# #     kind: AWSNodeTemplate
# #     metadata:
# #       name: default
# #     spec:
# #       subnetSelector:
# #         kubernetes.io/cluster/${aws_eks_cluster.cluster[0].name}: owned
# #       securityGroupSelector:
# #         kubernetes.io/cluster/${aws_eks_cluster.cluster[0].name}: owned
# #   YAML

# # }
