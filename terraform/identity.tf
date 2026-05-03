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
resource "aws_iam_role_policy" "runtime" {
  for_each = local.nodes
  role     = aws_iam_role.node[each.key].id
  policy = jsonencode({ Version = "2012-10-17", Statement = concat([
    { Effect = "Allow", Action = ["s3:GetObject", "s3:GetObjectVersion"], Resource = "${aws_s3_bucket.runtime.arn}/nodes/${each.key}.json" },
    { Effect = "Allow", Action = ["secretsmanager:GetSecretValue"], Resource = try(var.tls_secrets[each.key].arn, "MISSING") }
    ], length(var.secret_kms_key_arns) == 0 ? [] : [
    { Effect = "Allow", Action = ["kms:Decrypt"], Resource = sort(tolist(var.secret_kms_key_arns)), Condition = { StringEquals = { "kms:ViaService" = "secretsmanager.${var.region}.amazonaws.com" } } }
  ]) })
}
