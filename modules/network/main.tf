data "aws_region" "current" {}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
}

resource "aws_subnet" "public" {
  for_each                = { for idx, cidr in var.public_subnet_cidrs : idx => cidr }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = var.azs[tonumber(each.key)]
  map_public_ip_on_launch = true
  tags                    = { Tier = "web" }
}

resource "aws_subnet" "app" {
  for_each          = { for idx, cidr in var.app_subnet_cidrs : idx => cidr }
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = var.azs[tonumber(each.key)]
  tags              = { Tier = "app" }
}

resource "aws_subnet" "db" {
  for_each          = { for idx, cidr in var.db_subnet_cidrs : idx => cidr }
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = var.azs[tonumber(each.key)]
  tags              = { Tier = "db" }
}

resource "aws_eip" "nat" {
  count  = var.nat_mode == "per_az" ? length(var.azs) : 1
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  count         = var.nat_mode == "per_az" ? length(var.azs) : 1
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = values(aws_subnet.public)[count.index].id
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "app" {
  count  = var.nat_mode == "per_az" ? length(var.azs) : 1
  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = [1]
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat[var.nat_mode == "per_az" ? count.index : 0].id
    }
  }
}


resource "aws_route_table_association" "app" {
  for_each       = aws_subnet.app
  subnet_id      = each.value.id
  route_table_id = var.nat_mode == "per_az" ? aws_route_table.app[tonumber(each.key)].id : aws_route_table.app[0].id
}

resource "aws_route_table" "db" {
  count  = length(var.db_subnet_cidrs)
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table_association" "db" {
  for_each       = aws_subnet.db
  subnet_id      = each.value.id
  route_table_id = aws_route_table.db[tonumber(each.key)].id
}

resource "aws_vpc_endpoint" "ssm" {
  count               = var.enable_ssm_endpoints ? 1 : 0
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.id}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.app : s.id]
  security_group_ids  = [aws_security_group.endpoints[0].id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages" {
  count               = var.enable_ssm_endpoints ? 1 : 0
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.id}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.app : s.id]
  security_group_ids  = [aws_security_group.endpoints[0].id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2messages" {
  count               = var.enable_ssm_endpoints ? 1 : 0
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.id}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.app : s.id]
  security_group_ids  = [aws_security_group.endpoints[0].id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.id}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = concat(
    [aws_route_table.public.id],
    [for rt in aws_route_table.app : rt.id]
  )
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.id}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids = concat(
    [aws_route_table.public.id],
    [for rt in aws_route_table.app : rt.id]
  )
}

resource "aws_cloudwatch_log_group" "flow" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "${var.project}-${var.environment}-vpc-flowlogs"
  retention_in_days = 30
}

resource "aws_flow_log" "this" {
  count                = var.enable_flow_logs ? 1 : 0
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.flow[0].arn
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.this.id
  iam_role_arn         = aws_iam_role.flow_logs_role.arn
}

resource "aws_security_group" "endpoints" {
  count  = var.enable_ssm_endpoints ? 1 : 0
  name   = "vpc-endpoints"
  vpc_id = aws_vpc.this.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Private EKS subnets
resource "aws_subnet" "eks_private" {
  count             = length(var.eks_private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.eks_private_subnet_cidrs[count.index]
  availability_zone = element(var.azs, count.index)

  tags = {
    Name                                                          = "${var.project}-${var.environment}-eks-private-${count.index + 1}"
    "kubernetes.io/role/internal-elb"                             = "1"
    "kubernetes.io/cluster/${var.project}-${var.environment}-eks" = "shared"
  }
}

resource "aws_route_table" "eks_private" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.project}-${var.environment}-eks-private-rt"
  }
}

resource "aws_route" "eks_private_nat" {
  route_table_id         = aws_route_table.eks_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[0].id
}

resource "aws_route_table_association" "eks_private_assoc" {
  count          = length(aws_subnet.eks_private[*].id)
  subnet_id      = aws_subnet.eks_private[count.index].id
  route_table_id = aws_route_table.eks_private.id
}

#Public EKS subnets
resource "aws_subnet" "eks_public" {
  count                   = length(var.eks_public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.eks_public_subnet_cidrs[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name                                                          = "${var.project}-${var.environment}-eks-public-${count.index + 1}"
    "kubernetes.io/role/elb"                                      = "1"
    "kubernetes.io/cluster/${var.project}-${var.environment}-eks" = "shared"
  }
}

resource "aws_route_table" "eks_public" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.project}-${var.environment}-eks-public-rt"
  }
}

resource "aws_route" "eks_public_igw" {
  route_table_id         = aws_route_table.eks_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "eks_public_assoc" {
  count          = length(aws_subnet.eks_public[*].id)
  subnet_id      = aws_subnet.eks_public[count.index].id
  route_table_id = aws_route_table.eks_public.id
}
