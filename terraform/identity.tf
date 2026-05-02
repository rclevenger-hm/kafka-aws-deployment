resource "aws_iam_role" "node" {
  for_each           = local.nodes
  name_prefix        = "${each.key}-"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Action = "sts:AssumeRole", Principal = { Service = "ec2.amazonaws.com" } }] })
}
resource "aws_iam_instance_profile" "node" {
  for_each    = local.nodes
  name_prefix = "${each.key}-"
  role        = aws_iam_role.node[each.key].name
}
resource "aws_iam_role_policy_attachment" "ssm" {
  for_each   = local.nodes
  role       = aws_iam_role.node[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
