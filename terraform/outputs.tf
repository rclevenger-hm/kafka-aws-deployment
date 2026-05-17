output "bootstrap_servers" {
  description = "Private mTLS bootstrap addresses; requires network routing and Kafka ACLs."
  value       = join(",", [for name in keys(local.brokers) : "${name}.${var.dns_domain}:9092"])
}
output "cluster_id" { value = random_id.cluster.b64_url }
output "nodes" {
  value = { for name, node in local.nodes : name => {
    id              = aws_instance.node[name].id, role = node.role, zone = node.zone,
    address         = aws_instance.node[name].private_ip, fqdn = "${name}.${var.dns_domain}",
    volume_id       = aws_ebs_volume.data[name].id,
    runtime_version = aws_s3_object.node[name].version_id
  } }
}
