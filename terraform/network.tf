resource "aws_vpc" "kafka" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.name_prefix}-vpc" }
}
resource "aws_internet_gateway" "egress" { vpc_id = aws_vpc.kafka.id }
resource "aws_subnet" "private" {
  for_each                = local.azs
  vpc_id                  = aws_vpc.kafka.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, each.value)
  map_public_ip_on_launch = false
  tags                    = { Name = "${var.name_prefix}-private-${each.key}" }
}
resource "aws_subnet" "public" {
  for_each                = local.azs
  vpc_id                  = aws_vpc.kafka.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, each.value + 3)
  map_public_ip_on_launch = false
  tags                    = { Name = "${var.name_prefix}-egress-${each.key}" }
}
resource "aws_route_table" "public" { vpc_id = aws_vpc.kafka.id }
resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.egress.id
}
resource "aws_route_table_association" "public" {
  for_each       = local.azs
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}
resource "aws_eip" "nat" {
  for_each = local.azs
  domain   = "vpc"
}
