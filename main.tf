resource "aws_vpc" "wp-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = merge(var.common-tags, {
    "Name" = "${var.project_name}-${var.project_env}-vpc"
  })
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.wp-vpc.id
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = data.aws_availability_zones.azones.names[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch_public
  tags = merge(var.common-tags, {
    "Name"                   = "${var.project_name}-${var.project_env}-public-subnet-${count.index + 1}"
    "kubernetes.io/role/elb" = "1"
  })
}

resource "aws_subnet" "private_subnets" {
  count                   = length(var.private_subnets_cidr)
  vpc_id                  = aws_vpc.wp-vpc.id
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = data.aws_availability_zones.azones.names[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch_private
  tags = merge(var.common-tags, {
    "Name"                            = "${var.project_name}-${var.project_env}-private-subnet-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1"
  })
}

resource "aws_internet_gateway" "wp-igw" {
  vpc_id = aws_vpc.wp-vpc.id
  tags = merge(var.common-tags, {
    "Name" = "${var.project_name}-${var.project_env}-igw"
  })
}

resource "aws_eip" "wp-eips" {
  count  = length(var.public_subnets_cidr)
  domain = "vpc"
  tags = merge(var.common-tags, {
    "Name" = "${var.project_name}-${var.project_env}-eip-${count.index + 1}"
  })
  depends_on = [aws_internet_gateway.wp-igw]
}

resource "aws_nat_gateway" "wp-ngw" {
  count         = length(var.public_subnets_cidr)
  allocation_id = aws_eip.wp-eips[count.index].id
  subnet_id     = element(aws_subnet.public_subnets[*].id, count.index)
  tags = merge(var.common-tags, {
    "Name" = "${var.project_name}-${var.project_env}-ngw-${count.index + 1}"
  })
  depends_on = [aws_internet_gateway.wp-igw]
}

resource "aws_route_table" "rtb-public" {
  vpc_id = aws_vpc.wp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wp-igw.id
  }
  tags = merge(var.common-tags, {
    "Name" = "${var.project_name}-${var.project_env}-rtb-public"
  })
}

resource "aws_route_table" "rtb-private" {
  count  = length(var.private_subnets_cidr)
  vpc_id = aws_vpc.wp-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.wp-ngw[*].id, count.index)
  }
  tags = merge(var.common-tags, {
    "Name" = "${var.project_name}-${var.project_env}-rtb-private-${count.index + 1}"
  })
}

resource "aws_route_table_association" "public-assoc" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.rtb-public.id
}

resource "aws_route_table_association" "assoc-private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.rtb-private[count.index].id
}