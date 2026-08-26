mock_provider "aws" {
  override_during = plan
  mock_data "aws_ami" { defaults = { id = "ami-0123456789abcdef0" } }
  mock_resource "aws_s3_bucket" {
    defaults = { id = "kafka-test-runtime", arn = "arn:aws:s3:::kafka-test-runtime" }
  }
  mock_resource "aws_ebs_volume" { defaults = { id = "vol-0123456789abcdef0" } }
}
