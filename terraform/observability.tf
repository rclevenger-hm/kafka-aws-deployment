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
resource "aws_flow_log" "kafka" {
  count                    = var.enable_flow_logs ? 1 : 0
  iam_role_arn             = aws_iam_role.flow[0].arn
  log_destination          = aws_cloudwatch_log_group.flow[0].arn
  traffic_type             = "ALL"
  vpc_id                   = aws_vpc.kafka.id
  max_aggregation_interval = 60
  depends_on               = [aws_iam_role_policy.flow]
}
