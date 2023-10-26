locals {
  karpenter_namespace            = "karpenter"
  helm_karpenter_release_name    = join("-", [var.resource_name_prefix, "karpenter"])
  helm_karpenter_chart           = "karpenter"
  karpenter_helm_chart_version   = var.karpenter_helm_chart_version

}


#Karpenter
resource "helm_release" "karpenter" {
  #provider         = helm.default
  namespace        = local.karpenter_namespace
  create_namespace = true
  name             = local.helm_karpenter_release_name
  repository       = "https://charts.karpenter.sh"
  chart            = local.helm_karpenter_chart
  version          = local.karpenter_helm_chart_version

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = data.aws_iam_role.karpenter_controller.arn
  }

  set {
    name  = "clusterName"
    value = data.aws_eks_cluster.cluster.name
  }

  set {
    name  = "clusterEndpoint"
    value = data.aws_eks_cluster.cluster.endpoint
  }

  set {
    name  = "aws.defaultInstanceProfile"
    value = data.aws_iam_instance_profile.karpenter_instance.name
  }

  # Adjust depends_on if needed
  depends_on = [data.aws_eks_cluster.cluster]

}

resource "kubectl_manifest" "karpenter_node" {
  yaml_body = <<-EOT
  apiVersion: karpenter.sh/v1alpha5
  kind: Provisioner
  metadata:
    name: default
  spec:
    requirements:
      - key: karpenter.sh/capacity-type
        operator: In
        values: ["on-demand"]
    limits:
      resources:
        cpu: 1000
    provider:
      instanceProfile: ${data.aws_iam_instance_profile.karpenter_instance.name}
      subnetSelector:
        kubernetes.io/cluster/${local.eks_cluster_name}: owned
      securityGroupSelector:
        kubernetes.io/cluster/${local.eks_cluster_name}: owned
    ttlSecondsAfterEmpty: 30
  EOT

  depends_on = [
    data.aws_eks_cluster.cluster, helm_release.karpenter
  ]
}



# resource "local_file" "karpenter_provisioner" {
#   content = <<-EOT
# apiVersion: karpenter.sh/v1alpha5
# kind: Provisioner
# metadata:
#   name: mydef
# spec:
#   providerRef:
#     name: front-dev-karpenter-node
#   requirements:
#     - key: karpenter.k8s.aws/instance-family
#       operator: In
#       values:
#         ${jsonencode(var.instance_families)}
#     - key: karpenter.k8s.aws/instance-size
#       operator: In
#       values:
#         ${jsonencode(var.instance_sizes)}
#   ttlSecondsAfterEmpty: 30
#   ttlSecondsUntilExpired: 604800 # 7 days
# ---
# apiVersion: karpenter.k8s.aws/v1alpha1
# kind: AWSNodeTemplate
# metadata:
#   name: front-dev-karpenter-node
# spec:
#   subnetSelector:
#     kubernetes.io/cluster/${local.eks_cluster_name}: owned
#   securityGroupSelector:
#     kubernetes.io/cluster/${local.eks_cluster_name}: owned
# EOT

#   filename = "${path.module}/karpenter_provisioner.yaml"

#   depends_on = [ data.aws_eks_cluster.cluster, helm_release.karpenter ]
# }

# resource "null_resource" "apply_karpenter_provisioner" {
#   triggers = {
#     local_file_content = local_file.karpenter_provisioner.content
#   }

#   provisioner "local-exec" {
#     command = "kubectl apply -f ${path.module}/karpenter_provisioner.yaml"
#   }

#   depends_on = [data.aws_eks_cluster.cluster, helm_release.karpenter, local_file.karpenter_provisioner]
# }
