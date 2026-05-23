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
output "runtime_bucket" { value = aws_s3_bucket.runtime.id }
output "vpc_id" { value = aws_vpc.kafka.id }
output "private_subnet_ids" { value = { for zone, subnet in aws_subnet.private : zone => subnet.id } }
output "security_group_ids" { value = { for role, sg in aws_security_group.node : role => sg.id } }
output "session_commands" {
  value = { for name, node in aws_instance.node : name => "aws ssm start-session --region ${var.region} --target ${node.id}" }
}
