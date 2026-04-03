# Kafka on AWS

[![Validate Kafka deployment](https://github.com/rclevenger-hm/kafka-aws-deployment/actions/workflows/ci.yml/badge.svg)](https://github.com/rclevenger-hm/kafka-aws-deployment/actions/workflows/ci.yml)

A self-managed Apache Kafka 4.1.2 deployment on private EC2 instances: three dedicated KRaft controllers and three or more brokers across three availability zones. Terraform provisions the infrastructure; a guarded Python bootstrap installs the runtime; operating guides cover acceptance, recovery, upgrades and certificates.

This extends the [OCI deployment](https://github.com/rclevenger-hm/kafka-oci-deployment) and [GCP deployment](https://github.com/rclevenger-hm/kafka-gcp-deployment). See the [capability comparison](docs/parity.md) for implemented features and remaining live-cloud gates. This is a reference implementation, not a claim of completed AWS production qualification.

