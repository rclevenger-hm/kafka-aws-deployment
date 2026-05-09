resource "aws_ebs_volume" "data" {
  for_each          = local.nodes
  availability_zone = each.value.zone
  type              = "gp3"
  size              = each.value.role == "broker" ? var.broker_disk_gb : var.controller_disk_gb
  iops              = each.value.role == "broker" ? var.broker_disk_iops : 3000
  throughput        = each.value.role == "broker" ? var.broker_disk_throughput : 125
  encrypted         = true
  kms_key_id        = var.ebs_kms_key_arn
  tags              = { Name = "${each.key}-data", Role = each.value.role, Cluster = var.name_prefix }
  lifecycle { prevent_destroy = true }
}
