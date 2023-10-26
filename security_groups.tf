# locals {
#   front_api_lb_sg_name          = join("-", [var.resource_name_prefix, "lb", "sg"])
#   front_api_lb_sg_description   = "Front Office API Load Balancer Security Group"
#   front_api_lb_sg_ingress_ports = [80, 443]

#   front_api_rds_sg_name        = join("-", [var.resource_name_prefix, "rds", "sg"])
#   front_api_rds_sg_description = "Front Office RDS Security Group"

#   front_api_ecs_sg_name        = join("-", [var.resource_name_prefix, "ecs", "sg"])
#   front_api_ecs_sg_description = "Front Office ECS Security Group"

#   front_api_eks_sg_name        = join("-", [var.resource_name_prefix, "eks", "sg"])
#   front_api_eks_sg_description = "Front Office EKS Cluster communication with worker nodes"

#   workstation-external-cidr = ["0.0.0.0/0"]

#   front_vpc_link_sg_name        = join("-", [var.resource_name_prefix, "vpc", "link", "sg"])
#   front_vpc_link_sg_description = "Front Office VPC link Security Group"
# }

# resource "aws_security_group" "eks_cluster_sg" {
#   name        = local.front_api_eks_sg_name
#   description = local.front_api_eks_sg_description
#   vpc_id      = aws_vpc.main.id

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name                                              = local.front_api_eks_sg_name
#     "kubernetes.io/cluster/${local.eks_cluster_name}" = "owned"
#   }
# }

# resource "aws_security_group_rule" "cluster-ingress-workstation-https" {
#   cidr_blocks       = local.workstation-external-cidr
#   description       = "Allow workstation to communicate with the cluster API Server"
#   from_port         = 443
#   protocol          = "tcp"
#   security_group_id = aws_security_group.eks_cluster_sg.id
#   to_port           = 443
#   type              = "ingress"
# }

# resource "aws_security_group" "vpc_link" {
#   name        = local.front_vpc_link_sg_name
#   description = local.front_vpc_link_sg_description
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }
#   tags = {
#     Name = local.front_vpc_link_sg_name
#   }
# }
