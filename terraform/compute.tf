data "aws_ami" "node" {
  owners = ["amazon"]
  filter {
    name   = "image-id"
    values = [var.ami_id]
  }
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-*-x86_64"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
resource "aws_instance" "node" {
  for_each                    = local.nodes
  ami                         = data.aws_ami.node.id
  instance_type               = each.value.role == "broker" ? var.broker_instance_type : var.controller_instance_type
  subnet_id                   = aws_subnet.private[each.value.zone].id
  private_ip                  = cidrhost(aws_subnet.private[each.value.zone].cidr_block, each.value.host)
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.node[each.value.role].id]
  iam_instance_profile        = aws_iam_instance_profile.node[each.key].name
  disable_api_termination     = var.deletion_protection
  monitoring                  = true
  ebs_optimized               = true
  user_data = templatefile("${path.module}/../bootstrap/startup.sh", {
    bucket         = aws_s3_bucket.runtime.id, key = "nodes/${each.key}.json", region = var.region,
    refresh_source = file("${path.module}/../bootstrap/refresh.py")
  })
  user_data_replace_on_change = true
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }
  root_block_device {
    encrypted             = true
    kms_key_id            = var.ebs_kms_key_arn
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
  }
  tags = { Name = each.key, Role = each.value.role, Cluster = var.name_prefix }
  lifecycle {
    prevent_destroy = true
    precondition {
      condition = length(templatefile("${path.module}/../bootstrap/startup.sh", {
        bucket         = aws_s3_bucket.runtime.id, key = "nodes/${each.key}.json", region = var.region,
        refresh_source = file("${path.module}/../bootstrap/refresh.py")
      })) <= 16384
      error_message = "EC2 user data exceeds the 16 KiB limit."
    }
  }
  depends_on = [aws_route.egress, aws_route_table_association.private, aws_iam_role_policy.runtime, aws_iam_role_policy_attachment.ssm, aws_s3_object.node, aws_route53_record.node, aws_vpc_endpoint.management, aws_s3_bucket_policy.runtime]
}
