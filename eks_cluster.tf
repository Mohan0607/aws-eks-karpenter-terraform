locals {
  eks_cluster_name = join("-", [var.resource_name_prefix, "eks-cluster"])

}
resource "aws_eks_cluster" "cluster" {
  count    = local.enable_eks_service
  name     = local.eks_cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_cluster[0].arn

  vpc_config {

    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs     = var.public_access_cidrs
    #security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    subnet_ids = concat(aws_subnet.private_egress[*].id, aws_subnet.bastion[*].id)

  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}