resource "aws_iam_role" "node" {
  for_each           = local.nodes
  name_prefix        = "${each.key}-"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Action = "sts:AssumeRole", Principal = { Service = "ec2.amazonaws.com" } }] })
}
