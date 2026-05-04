resource "aws_security_group" "node" {
  for_each    = toset(["broker", "controller"])
  name_prefix = "${var.name_prefix}-${each.key}-"
  description = "Private Kafka ${each.key}; no SSH or public listeners"
  vpc_id      = aws_vpc.kafka.id
}
