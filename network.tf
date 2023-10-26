locals {
  vpc_name    = join("-", [var.resource_name_prefix, "vpc"])
  igw_name    = join("-", [var.resource_name_prefix, "igw"])
  nat_gw_name = join("-", [var.resource_name_prefix, "nat-gw"])

  bastion_rtb_name                    = join("-", [var.resource_name_prefix, "bastion", "rtb"])
  private_rtb_name                    = join("-", [var.resource_name_prefix, "private", "rtb"])
  private_egress_rtb_name             = join("-", [var.resource_name_prefix, "private", "egress", "rtb"])
  private_egress_db_subnet_group_name = join("-", [var.resource_name_prefix, "db-subnet-group"])
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  # Must be enabled for EFS
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = local.vpc_name
  }
}


resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = local.igw_name
  }
}


resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_gw.id
  subnet_id     = aws_subnet.bastion[0].id

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = local.nat_gw_name
  }

}


resource "aws_eip" "nat_gw" {
  vpc = true
}



# Bastion Subnet
resource "aws_subnet" "bastion" {
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  count             = length(var.bastion_subnets_cidr_list)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.bastion_subnets_cidr_list[count.index]

  tags = {
    Name                                              = join("-", [var.resource_name_prefix, "bastion", data.aws_availability_zones.available.names[count.index]])
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "owned"
    "kubernetes.io/role/elb"                          = "1"
  }
}


resource "aws_route_table" "bastion" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = local.bastion_rtb_name
  }
}

resource "aws_route" "bastion_internet" {
  route_table_id         = aws_route_table.bastion.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "bastion" {
  count          = length(aws_subnet.bastion[*].id)
  subnet_id      = aws_subnet.bastion[count.index].id
  route_table_id = aws_route_table.bastion.id
}


# Private Subnet without internet access

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = false

  count             = length(var.private_subnets_cidr_list)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.private_subnets_cidr_list[count.index]

  tags = {
    Name = join("-", [var.resource_name_prefix, "private", data.aws_availability_zones.available.names[count.index]])

  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = local.private_rtb_name
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private[*].id)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


# Private with Internet access
resource "aws_subnet" "private_egress" {
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = false

  count             = length(var.private_egress_subnets_cidr_list)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.private_egress_subnets_cidr_list[count.index]

  tags = {
    Name                                              = join("-", [var.resource_name_prefix, "private-egress", data.aws_availability_zones.available.names[count.index]])
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb"                 = "1"
  }
}


resource "aws_route_table" "private_egress" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = local.private_egress_rtb_name
  }
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private_egress.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "private_egress" {
  count     = length(aws_subnet.private_egress[*].id)
  subnet_id = aws_subnet.private_egress[count.index].id

  route_table_id = aws_route_table.private_egress.id
}

resource "aws_db_subnet_group" "private_egress" {
  name       = local.private_egress_db_subnet_group_name
  subnet_ids = aws_subnet.private_egress[*].id

  tags = {
    Name = local.private_egress_db_subnet_group_name
  }
}