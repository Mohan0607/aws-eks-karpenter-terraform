resource "aws_iam_policy" "ecs_task_execution" {

  name = join("-", [var.resource_name_prefix, "ecs-task-execution-policy"])

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "ssm:GetParameter",
            "ssm:GetParameters"
        ],
        "Resource": [
            "arn:aws:ssm:*:791768447655:parameter/*"
        ]
    },
    {
            "Effect": "Allow",
            "Action": "logs:*",
            "Resource": "*"
      }
    ]
}
EOF
}

# Eks 
resource "aws_iam_role" "eks_cluster" {
  count = local.enable_eks_service

  name = join("-", [var.resource_name_prefix, "eks-cluster-role"])

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  count      = local.enable_eks_service
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster[0].name
}

resource "aws_iam_openid_connect_provider" "eks" {
  count           = local.enable_eks_service
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks[count.index].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.cluster[0].identity[0].oidc[0].issuer
}

# Worker Nodes
resource "aws_iam_role" "nodes" {
  count = local.enable_eks_service
  name  = join("-", [var.resource_name_prefix, "eks-node-group"])
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "secrets_manager_policy" {
  count = local.enable_eks_service
  name  = join("-", [var.resource_name_prefix, "eks-node-group-SecretsManagerAccessPolicy"])

  description = "Policy to grant access to Amazon Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:ListSecrets",
          "secretsmanager:DescribeSecret",
        ],
        Effect   = "Allow",
        Resource = "*",
      },
    ],
  })
}

resource "aws_iam_policy_attachment" "secrets_manager_policy_attachment" {
  count = local.enable_eks_service

  name       = "secrets_manager_attachment"
  policy_arn = aws_iam_policy.secrets_manager_policy[0].arn
  roles      = [aws_iam_role.nodes[0].name]
}
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  count = local.enable_eks_service

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes[0].name
}
resource "aws_iam_role_policy_attachment" "eks_managed_worker_node_policy" {
  count = local.enable_eks_service

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.nodes[0].name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  count = local.enable_eks_service

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes[0].name
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  count = local.enable_eks_service

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes[0].name
}

# CSI driver
data "aws_iam_policy_document" "csi_assume_role_policy" {
  count = local.enable_eks_service

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringLike"
      variable = "${replace(aws_iam_openid_connect_provider.eks[0].url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${local.csi_driver_namespace}:csi-secrets-store-provider-aws"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks[0].arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "csi" {
  count              = local.enable_eks_service
  name_prefix        = join("-", [local.csi_driver_name_prefix, "role"])
  description        = "IAM Role for Front Office CSI Driver"
  assume_role_policy = data.aws_iam_policy_document.csi_assume_role_policy[0].json
}

resource "aws_iam_role_policy_attachment" "csi" {
  count      = local.enable_eks_service
  policy_arn = aws_iam_policy.ecs_task_execution.arn
  role       = aws_iam_role.csi[0].name
}