resource "aws_security_group" "node" {
  for_each    = toset(["broker", "controller"])
  name_prefix = "${var.name_prefix}-${each.key}-"
  description = "Private Kafka ${each.key}; no SSH or public listeners"
  vpc_id      = aws_vpc.kafka.id
}
resource "aws_vpc_security_group_egress_rule" "node" {
  for_each          = aws_security_group.node
  security_group_id = each.value.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "NAT egress for distribution and verified artifacts; constrain with an egress proxy if required"
}
