resource "aws_route53_zone" "kafka" {
  name = var.dns_domain
  vpc { vpc_id = aws_vpc.kafka.id }
  comment = "Private Kafka DNS; node certificates must include these names"
}
