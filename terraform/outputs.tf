output "bootstrap_servers" {
  description = "Private mTLS bootstrap addresses; requires network routing and Kafka ACLs."
  value       = join(",", [for name in keys(local.brokers) : "${name}.${var.dns_domain}:9092"])
}
