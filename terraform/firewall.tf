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
resource "aws_vpc_security_group_ingress_rule" "quorum" {
  for_each                     = aws_security_group.node
  security_group_id            = aws_security_group.node["controller"].id
  referenced_security_group_id = each.value.id
  ip_protocol                  = "tcp"
  from_port                    = 9093
  to_port                      = 9093
}
resource "aws_vpc_security_group_ingress_rule" "replication" {
  for_each                     = aws_security_group.node
  security_group_id            = aws_security_group.node["broker"].id
  referenced_security_group_id = each.value.id
  ip_protocol                  = "tcp"
  from_port                    = 9094
  to_port                      = 9094
}
resource "aws_vpc_security_group_ingress_rule" "clients" {
  for_each          = var.client_cidrs
  security_group_id = aws_security_group.node["broker"].id
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 9092
  to_port           = 9092
}
locals {
  metrics_rules = { for pair in setproduct(["broker", "controller"], var.metrics_cidrs) : "${pair[0]}-${pair[1]}" => { role = pair[0], cidr = pair[1] } }
}
resource "aws_vpc_security_group_ingress_rule" "metrics" {
  for_each          = local.metrics_rules
  security_group_id = aws_security_group.node[each.value.role].id
  cidr_ipv4         = each.value.cidr
  ip_protocol       = "tcp"
  from_port         = 9404
  to_port           = 9404
}
