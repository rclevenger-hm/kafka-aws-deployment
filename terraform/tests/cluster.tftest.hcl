mock_provider "aws" {
  override_during = plan
  mock_data "aws_ami" { defaults = { id = "ami-0123456789abcdef0" } }
  mock_resource "aws_s3_bucket" {
    defaults = { id = "kafka-test-runtime", arn = "arn:aws:s3:::kafka-test-runtime" }
  }
  mock_resource "aws_ebs_volume" { defaults = { id = "vol-0123456789abcdef0" } }
}
mock_provider "random" {
  override_during = plan
  mock_resource "random_id" { defaults = { b64_url = "AAAAAAAAAAAAAAAAAAAAAA" } }
}
variables {
  ami_id = "ami-0123456789abcdef0"
  tls_secrets = {
    kafka-controller-1 = { arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:kafka-controller-1-ABCDEF", version_id = "11111111-2222-3333-4444-555555555555" }
    kafka-controller-2 = { arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:kafka-controller-2-ABCDEF", version_id = "11111111-2222-3333-4444-555555555555" }
    kafka-controller-3 = { arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:kafka-controller-3-ABCDEF", version_id = "11111111-2222-3333-4444-555555555555" }
    kafka-broker-1     = { arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:kafka-broker-1-ABCDEF", version_id = "11111111-2222-3333-4444-555555555555" }
    kafka-broker-2     = { arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:kafka-broker-2-ABCDEF", version_id = "11111111-2222-3333-4444-555555555555" }
    kafka-broker-3     = { arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:kafka-broker-3-ABCDEF", version_id = "11111111-2222-3333-4444-555555555555" }
  }
}

run "private_topology" {
  command = plan
  assert {
    condition     = length(aws_instance.node) == 6 && length(aws_ebs_volume.data) == 6
    error_message = "Six separate compute and storage identities required."
  }
  assert {
    condition     = alltrue([for n in aws_instance.node : !n.associate_public_ip_address])
    error_message = "Nodes must never have public addresses."
  }
  assert {
    condition     = length(aws_subnet.private) == 3 && length(aws_nat_gateway.egress) == 3
    error_message = "Each availability zone requires its own subnet and NAT."
  }
  assert {
    condition     = length(toset([for n in local.controllers : n.zone])) == 3
    error_message = "Controllers must span three zones."
  }
  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.clients) == 0 && length(aws_vpc_security_group_ingress_rule.metrics) == 0
    error_message = "Client and collector ingress default closed."
  }
  assert {
    condition     = alltrue([for n in aws_instance.node : n.metadata_options[0].http_tokens == "required" && n.metadata_options[0].http_put_response_hop_limit == 1])
    error_message = "Require IMDSv2 with a single hop."
  }
  assert {
    condition     = alltrue([for n in aws_instance.node : n.disable_api_termination && n.root_block_device[0].encrypted])
    error_message = "Preserve termination protection and encrypted boot disks."
  }
  assert {
    condition     = alltrue([for n in aws_ebs_volume.data : n.encrypted && n.type == "gp3"])
    error_message = "Data volumes must be encrypted gp3."
  }
  assert {
    condition     = length(aws_vpc_endpoint.management) == 3 && aws_vpc_endpoint.s3.vpc_endpoint_type == "Gateway"
    error_message = "Provide private AWS management and S3 paths."
  }
  assert {
    condition     = alltrue([for n in aws_instance.node : length(n.user_data) <= 16384])
    error_message = "Bootstrap must remain below the EC2 user-data limit."
  }
}

