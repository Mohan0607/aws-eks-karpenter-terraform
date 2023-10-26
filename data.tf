data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_elb_service_account" "main" {}

data "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskExecutionRole"
}

data "tls_certificate" "eks" {
  count = local.enable_eks_service
  url   = aws_eks_cluster.cluster[0].identity[0].oidc[0].issuer
}
data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "cluster" {
  count      = local.enable_eks_service
  name       = aws_eks_cluster.cluster[0].id
  depends_on = [aws_eks_cluster.cluster]
}
