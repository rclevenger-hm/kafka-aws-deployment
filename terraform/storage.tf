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
resource "aws_volume_attachment" "data" {
  for_each                       = local.nodes
  device_name                    = "/dev/sdf"
  volume_id                      = aws_ebs_volume.data[each.key].id
  instance_id                    = aws_instance.node[each.key].id
  force_detach                   = false
  stop_instance_before_detaching = true
}
resource "aws_s3_bucket" "runtime" {
  bucket_prefix = "${var.name_prefix}-runtime-"
  force_destroy = false
  lifecycle { prevent_destroy = true }
}
