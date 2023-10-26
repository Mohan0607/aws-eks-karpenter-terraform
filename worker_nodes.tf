resource "aws_eks_node_group" "nodes" {
  count           = local.enable_eks_service
  cluster_name    = aws_eks_cluster.cluster[0].name
  version         = var.cluster_version
  node_group_name = join("-", [var.resource_name_prefix, "eks-node-group"])
  node_role_arn   = aws_iam_role.nodes[0].arn

  subnet_ids = concat(aws_subnet.private_egress[*].id)

  capacity_type  = var.capacity_type
  instance_types = var.instance_types

  scaling_config {
    desired_size = var.scaling_config.desired_size
    max_size     = var.scaling_config.max_size
    min_size     = var.scaling_config.min_size
  }
  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_read_only,
  ]

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}
