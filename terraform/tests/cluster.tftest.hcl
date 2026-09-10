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

run "client_allowlist" {
  command = plan
  variables {
    client_cidrs = ["10.60.0.0/24"]
  }
  assert {
    condition     = aws_vpc_security_group_ingress_rule.clients["10.60.0.0/24"].from_port == 9092 && aws_vpc_security_group_ingress_rule.clients["10.60.0.0/24"].to_port == 9092
    error_message = "Clients may reach only the client listener."
  }
}

run "metrics_allowlist" {
  command = plan
  variables {
    metrics_cidrs = ["10.60.1.0/24"]
  }
  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.metrics) == 2 && alltrue([for r in aws_vpc_security_group_ingress_rule.metrics : r.from_port == 9404 && r.to_port == 9404])
    error_message = "Allow explicit collectors to both node roles only at the exporter port."
  }
}

run "private_endpoint_opt_out" {
  command = plan
  variables {
    enable_private_endpoints = false
  }
  assert {
    condition     = length(aws_vpc_endpoint.management) == 0 && length(aws_nat_gateway.egress) == 3
    error_message = "Endpoint opt out retains NAT for management and artifacts."
  }
}

run "flow_log_opt_out" {
  command = plan
  variables {
    enable_flow_logs = false
  }
  assert {
    condition     = length(aws_flow_log.kafka) == 0 && length(aws_cloudwatch_log_group.flow) == 0
    error_message = "Flow log opt out removes the logging resources."
  }
}

run "per_node_secret_access" {
  command = plan
  assert {
    condition     = alltrue([for name, policy in aws_iam_role_policy.runtime : jsondecode(policy.policy).Statement[1].Resource == var.tls_secrets[name].arn])
    error_message = "IAM may read only the corresponding node secret."
  }
  assert {
    condition     = alltrue([for name, policy in aws_iam_role_policy.runtime : endswith(jsondecode(policy.policy).Statement[0].Resource, "/nodes/${name}.json")])
    error_message = "Runtime object access must be scoped to one node."
  }
}

run "runtime_updates_are_staged" {
  command = plan
  assert {
    condition     = alltrue([for name, object in aws_s3_object.node : jsondecode(object.content).config.tls_secret_version == var.tls_secrets[name].version_id])
    error_message = "Runtime manifests must pin secret versions."
  }
  assert {
    condition     = alltrue([for object in aws_s3_object.node : !strcontains(object.content, "BEGIN PRIVATE KEY")])
    error_message = "Private keys must not enter S3 runtime manifests or Terraform state."
  }
}

run "custom_gp3_performance" {
  command = plan
  variables {
    broker_disk_iops       = 6000
    broker_disk_throughput = 250
  }
  assert {
    condition     = aws_ebs_volume.data["kafka-broker-1"].iops == 6000 && aws_ebs_volume.data["kafka-broker-1"].throughput == 250
    error_message = "Expose explicit broker EBS performance."
  }
  assert {
    condition     = aws_ebs_volume.data["kafka-controller-1"].iops == 3000
    error_message = "Keep controller disk profile separate."
  }
}

run "same_zone_storage" {
  command = plan
  assert {
    condition     = alltrue([for name, volume in aws_ebs_volume.data : volume.availability_zone == local.nodes[name].zone])
    error_message = "An EBS volume must be in the same zone as its node."
  }
}

run "pinned_ami" {
  command = plan
  assert {
    condition     = alltrue([for n in aws_instance.node : n.ami == "ami-0123456789abcdef0"])
    error_message = "Use the selected pinned AMI."
  }
}

run "no_forced_detach" {
  command = plan
  assert {
    condition     = alltrue([for a in aws_volume_attachment.data : !a.force_detach && a.stop_instance_before_detaching])
    error_message = "Detach must be graceful, with the instance stopped."
  }
}

run "reject_public_clients" {
  command = plan
  variables { client_cidrs = ["0.0.0.0/0"] }
  expect_failures = [var.client_cidrs]
}

run "reject_public_metrics" {
  command = plan
  variables { metrics_cidrs = ["8.8.8.0/24"] }
  expect_failures = [var.metrics_cidrs]
}

run "reject_broad_private_clients" {
  command = plan
  variables { client_cidrs = ["192.168.0.0/8"] }
  expect_failures = [var.client_cidrs]
}

run "reject_public_vpc" {
  command = plan
  variables { vpc_cidr = "8.8.0.0/16" }
  expect_failures = [var.vpc_cidr]
}

run "reject_tiny_vpc" {
  command = plan
  variables { vpc_cidr = "10.42.0.0/28" }
  expect_failures = [var.vpc_cidr]
}

run "reject_ipv6" {
  command = plan
  variables { vpc_cidr = "fd00::/64" }
  expect_failures = [var.vpc_cidr]
}

run "reject_fractional_brokers" {
  command = plan
  variables { broker_count = 3.5 }
  expect_failures = [var.broker_count]
}

run "reject_too_few_brokers" {
  command = plan
  variables { broker_count = 2 }
  expect_failures = [var.broker_count]
}

run "reject_duplicate_zones" {
  command = plan
  variables { zones = ["us-east-1a", "us-east-1a", "us-east-1c"] }
  expect_failures = [var.zones]
}

