resource "aws_vpc" "kafka" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.name_prefix}-vpc" }
}
resource "aws_internet_gateway" "egress" { vpc_id = aws_vpc.kafka.id }
