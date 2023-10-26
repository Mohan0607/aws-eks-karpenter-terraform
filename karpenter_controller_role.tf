data "aws_iam_policy_document" "karpenter_controller_assume_role_policy" {
  count = local.enable_eks_service

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks[0].url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${local.karpenter_namespace}:karpenter"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks[0].arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_policy" "karpenter_controller" {
  count = local.enable_eks_service
  name  = join("-", [var.resource_name_prefix, "karpenter-controllers-policy"])
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRoleWithWebIdentity",
          "ssm:GetParameter",
          "iam:PassRole",
          "ec2:RunInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateTags",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet"
        ],
        Effect   = "Allow",
        Resource = "*",
        Sid      = "Karpenter"
      },
      {
        Action = "ec2:TerminateInstances",
        Condition = {
          StringLike = {
            "ec2:ResourceTag/Name" = ["*karpenter*", "front-dev*"]
          }
        },
        Effect   = "Allow",
        Resource = "*",
        Sid      = "ConditionalEC2Termination"
      }
    ]
  })
}



resource "aws_iam_role" "karpenter_controller" {
  count              = local.enable_eks_service
  assume_role_policy = data.aws_iam_policy_document.karpenter_controller_assume_role_policy[0].json
  name               = join("-", [var.resource_name_prefix, "karpenter-controllers-role"])
}

resource "aws_iam_role_policy_attachment" "karpenter_controller_attach" {
  count      = local.enable_eks_service
  role       = aws_iam_role.karpenter_controller[0].name
  policy_arn = aws_iam_policy.karpenter_controller[0].arn
}

resource "aws_iam_instance_profile" "karpenter" {
  count = local.enable_eks_service
  name  = join("-", [var.resource_name_prefix, "karpenter-node-instance-profiles"])
  role  = aws_iam_role.nodes[0].name
}
