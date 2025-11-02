resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "${var.name}-vpc" }
}

resource "aws_internet_gateway" "igw" { vpc_id = aws_vpc.this.id }

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public" {
  for_each                = { for idx, cidr in var.public_cidrs : idx => cidr }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, tonumber(each.key))
  tags = { Name = "${var.name}-public-${each.key}" }
}

resource "aws_route_table" "public" { vpc_id = aws_vpc.this.id }

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count  = var.create_nat_gateway ? 1 : 0
  domain = "vpc"
}


resource "aws_nat_gateway" "nat" {
  count         = var.create_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = element(values(aws_subnet.public)[*].id, 0)
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_subnet" "private" {
  for_each          = { for idx, cidr in var.private_cidrs : idx => cidr }
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = element(data.aws_availability_zones.available.names, tonumber(each.key))
  tags = { Name = "${var.name}-private-${each.key}" }
}

resource "aws_route_table" "private" {
  count  = length(var.private_cidrs)
  vpc_id = aws_vpc.this.id
}

resource "aws_route" "private_nat" {
  count                 = var.create_nat_gateway ? length(var.private_cidrs) : 0
  route_table_id        = aws_route_table.private[count.index].id
  destination_cidr_block= "0.0.0.0/0"
  nat_gateway_id        = aws_nat_gateway.nat[0].id
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = element(aws_route_table.private[*].id, tonumber(each.key))
}

output "vpc_id"             { value = aws_vpc.this.id }
output "public_subnet_ids"  { value = [for s in aws_subnet.public  : s.id] }
output "private_subnet_ids" { value = [for s in aws_subnet.private : s.id] }