resource "aws_route53_zone" "kafka" {
  name = var.dns_domain
  vpc { vpc_id = aws_vpc.kafka.id }
  comment = "Private Kafka DNS; node certificates must include these names"
}
resource "aws_route53_record" "node" {
  for_each = local.nodes
  zone_id  = aws_route53_zone.kafka.zone_id
  name     = "${each.key}.${var.dns_domain}"
  type     = "A"
  ttl      = 60
  records  = [cidrhost(aws_subnet.private[each.value.zone].cidr_block, each.value.host)]
}
