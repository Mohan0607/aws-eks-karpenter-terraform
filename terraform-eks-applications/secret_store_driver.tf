# locals {
#   csi_driver_name_prefix    = join("-", [var.resource_name_prefix, "csi-driver"])
#   helm_eks_csi_release_name = local.csi_driver_name_prefix
#   eks_csi_chart_name        = "secrets-store-csi-driver"
#   csi_driver_namespace      = "kube-system"
# }

# resource "helm_release" "secrets_store_csi_driver" {
#   name       = local.helm_eks_csi_release_name
#   repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
#   chart      = local.eks_csi_chart_name
#   namespace  = local.csi_driver_namespace # Optional: Change this to your desired namespace
#   set {
#     name  = "enableSecretRotation"
#     value = "true"
#   }

#   set {
#     name  = "rotationPollInterval"
#     value = var.rotation_poll_interval_time
#   }
# }

# resource "kubectl_manifest" "secrets_store_provider_sa" {
#   yaml_body = <<-YAML
#     apiVersion: v1
#     kind: ServiceAccount
#     metadata:
#       name: csi-secrets-store-provider-aws
#       namespace: kube-system
#   YAML

#   depends_on = [
#     data.aws_eks_cluster.cluster
#   ]
# }

# resource "kubectl_manifest" "secrets_store_provider_cluster_role" {
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
#     data.aws_eks_cluster.cluster
#   ]
# }

# resource "kubectl_manifest" "secrets_store_provider_cluster_binding" {
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
#     data.aws_eks_cluster.cluster
#   ]
# }

# resource "kubectl_manifest" "secrets_store_provider_deamonset" {
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
#     data.aws_eks_cluster.cluster
#   ]
# }
