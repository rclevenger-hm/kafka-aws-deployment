resource "aws_cloudwatch_log_group" "flow" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "/${var.name_prefix}/vpc-flow"
  retention_in_days = var.log_retention_days
}
resource "aws_iam_role" "flow" {
  count              = var.enable_flow_logs ? 1 : 0
  name_prefix        = "${var.name_prefix}-flow-"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Action = "sts:AssumeRole", Principal = { Service = "vpc-flow-logs.amazonaws.com" } }] })
}
resource "aws_iam_role_policy" "flow" {
  count = var.enable_flow_logs ? 1 : 0
  role  = aws_iam_role.flow[0].id
  policy = jsonencode({ Version = "2012-10-17", Statement = [
    { Effect = "Allow", Action = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"], Resource = "${aws_cloudwatch_log_group.flow[0].arn}:*" },
    { Effect = "Allow", Action = ["logs:DescribeLogGroups"], Resource = "*" }
  ] })
}
