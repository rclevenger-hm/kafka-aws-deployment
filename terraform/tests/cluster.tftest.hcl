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

