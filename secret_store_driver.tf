# locals {
#   helm_eks_csi_release_name = join("-", [var.resource_name_prefix, "csi-driver"])
#   eks_csi_chart_name        = "secrets-store-csi-driver"
#   eks_csi_driver_namespace  = "kube-system"
# }

# provider "helm" {
#   alias = "csidriver"
#   kubernetes {
#     host = length(aws_eks_cluster.cluster) > 0 ? aws_eks_cluster.cluster[0].endpoint : null

#     cluster_ca_certificate = local.eks_cluster_exists ? base64decode(aws_eks_cluster.cluster[0].certificate_authority[0].data) : null
#     token                  = length(data.aws_eks_cluster_auth.cluster) > 0 ? data.aws_eks_cluster_auth.cluster[0].token : null
#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       args        = ["eks", "get-token", "--cluster-name", length(aws_eks_cluster.cluster) > 0 ? aws_eks_cluster.cluster[0].id : "", "--profile", var.local_aws_profile_name]

#       command = "aws"
#     }
#   }
# }

# provider "kubectl" {
#   alias = "csidriver"

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
#   alias = "csidriver"
#   host  = length(aws_eks_cluster.cluster) > 0 ? aws_eks_cluster.cluster[0].endpoint : null

#   cluster_ca_certificate = local.eks_cluster_exists ? base64decode(aws_eks_cluster.cluster[0].certificate_authority[0].data) : null
#   token                  = length(data.aws_eks_cluster_auth.cluster) > 0 ? data.aws_eks_cluster_auth.cluster[0].token : null
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args        = ["eks", "get-token", "--cluster-name", length(aws_eks_cluster.cluster) > 0 ? aws_eks_cluster.cluster[0].id : "", "--profile", var.local_aws_profile_name]

#   }
# }

# resource "helm_release" "secrets_store_csi_driver" {
#   provider   = helm.csidriver
#   count      = local.enable_eks_service
#   name       = local.helm_eks_csi_release_name
#   repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
#   chart      = local.eks_csi_chart_name
#   namespace  = local.eks_csi_driver_namespace # Optional: Change this to your desired namespace
#   set {
#     name  = "enableSecretRotation"
#     value = "true"
#   }

#   set {
#     name  = "rotationPollInterval"
#     value = "500s"
#   }
# }

# resource "kubectl_manifest" "secrets_store_provider_sa" {
#   provider  = kubectl.csidriver
#   count     = local.enable_eks_service
#   yaml_body = <<-YAML
#     apiVersion: v1
#     kind: ServiceAccount
#     metadata:
#       name: csi-secrets-store-provider-aws
#       namespace: kube-system
#   YAML

#   depends_on = [
#     aws_eks_cluster.cluster
#   ]
# }

# resource "kubectl_manifest" "secrets_store_provider_cluster_role" {
#   provider  = kubectl.csidriver
#   count     = local.enable_eks_service
#   yaml_body = <<-YAML
#     apiVersion: rbac.authorization.k8s.io/v1
#     kind: ClusterRole
#     metadata:
#       name: csi-secrets-store-provider-aws-cluster-role
#     rules:
#     - apiGroups: [""]
#       resources: ["serviceaccounts/token"]
#       verbs: ["create"]
#     - apiGroups: [""]
#       resources: ["serviceaccounts"]
#       verbs: ["get"]
#     - apiGroups: [""]
#       resources: ["pods"]
#       verbs: ["get"]
#     - apiGroups: [""]
#       resources: ["nodes"]
#       verbs: ["get"]
#   YAML

#   depends_on = [
#     aws_eks_cluster.cluster
#   ]
# }

# resource "kubectl_manifest" "secrets_store_provider_cluster_binding" {
#   provider  = kubectl.csidriver
#   count     = local.enable_eks_service
#   yaml_body = <<-YAML
#     apiVersion: rbac.authorization.k8s.io/v1
#     kind: ClusterRoleBinding
#     metadata:
#       name: csi-secrets-store-provider-aws-cluster-rolebinding
#     roleRef:
#       apiGroup: rbac.authorization.k8s.io
#       kind: ClusterRole
#       name: csi-secrets-store-provider-aws-cluster-role
#     subjects:
#     - kind: ServiceAccount
#       name: csi-secrets-store-provider-aws
#       namespace: kube-system
#   YAML

#   depends_on = [
#     aws_eks_cluster.cluster
#   ]
# }

# resource "kubectl_manifest" "secrets_store_provider_deamonset" {
#   provider  = kubectl.csidriver
#   count     = local.enable_eks_service
#   yaml_body = <<-YAML
#     apiVersion: apps/v1
#     kind: DaemonSet
#     metadata:
#       namespace: kube-system
#       name: csi-secrets-store-provider-aws
#       labels:
#         app: csi-secrets-store-provider-aws
#     spec:
#       updateStrategy:
#         type: RollingUpdate
#       selector:
#         matchLabels:
#           app: csi-secrets-store-provider-aws
#       template:
#         metadata:
#           labels:
#             app: csi-secrets-store-provider-aws
#         spec:
#           serviceAccountName: csi-secrets-store-provider-aws
#           hostNetwork: true
#           containers:
#             - name: provider-aws-installer
#               image: public.ecr.aws/aws-secrets-manager/secrets-store-csi-driver-provider-aws:1.0.r1-10-g1942553-2021.06.04.00.07-linux-amd64
#               imagePullPolicy: Always
#               args:
#                 - --provider-volume=/etc/kubernetes/secrets-store-csi-providers
#               resources:
#                 requests:
#                   cpu: 50m
#                   memory: 100Mi
#                 limits:
#                   cpu: 50m
#                   memory: 100Mi
#               volumeMounts:
#                 - mountPath: "/etc/kubernetes/secrets-store-csi-providers"
#                   name: providervol
#                 - name: mountpoint-dir
#                   mountPath: /var/lib/kubelet/pods
#                   mountPropagation: HostToContainer
#           volumes:
#             - name: providervol
#               hostPath:
#                 path: "/etc/kubernetes/secrets-store-csi-providers"
#             - name: mountpoint-dir
#               hostPath:
#                 path: /var/lib/kubelet/pods
#                 type: DirectoryOrCreate
#           nodeSelector:
#             kubernetes.io/os: linux
#   YAML

#   depends_on = [
#     aws_eks_cluster.cluster
#   ]
# }
