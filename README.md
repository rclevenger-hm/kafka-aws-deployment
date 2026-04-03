# Kafka on AWS

[![Validate Kafka deployment](https://github.com/rclevenger-hm/kafka-aws-deployment/actions/workflows/ci.yml/badge.svg)](https://github.com/rclevenger-hm/kafka-aws-deployment/actions/workflows/ci.yml)

A self-managed Apache Kafka 4.1.2 deployment on private EC2 instances: three dedicated KRaft controllers and three or more brokers across three availability zones. Terraform provisions the infrastructure; a guarded Python bootstrap installs the runtime; operating guides cover acceptance, recovery, upgrades and certificates.

This extends the [OCI deployment](https://github.com/rclevenger-hm/kafka-oci-deployment) and [GCP deployment](https://github.com/rclevenger-hm/kafka-gcp-deployment). See the [capability comparison](docs/parity.md) for implemented features and remaining live-cloud gates. This is a reference implementation, not a claim of completed AWS production qualification.

## What is included

- Private VPC subnets, one NAT gateway per zone, Route 53 private DNS and private AWS management endpoints.
- Dedicated encrypted gp3 volumes, stable node identities, disk-format protection and destruction guards.
- Mandatory IMDSv2, Session Manager administration, per-node instance profiles and Secrets Manager access.
- Mutual TLS on all Kafka listeners, hostname verification, default-deny ACLs, RF3 and minimum ISR2.
- Versioned S3 runtime manifests that stage configuration separately from controlled one-node restarts.
- Checksum-verified Kafka and JMX exporter downloads, an unprivileged hardened systemd service, and lab PKI tooling.
- Health and roundtrip tools, capacity estimates, Prometheus alerts, Grafana panels, VPC flow logs and EC2 status alarms.
- Python regressions, Terraform mock plans and a real six-process Kafka exercise covering TLS, authorization, broker outage writes and controller leader failover.

## Start here

Read [deployment](docs/deployment.md), [security](docs/security.md) and [capacity and cost](docs/capacity-planning.md). Supply a reviewed Amazon Linux 2023 x86_64 AMI, three available zones, a state bucket and one existing TLS secret per node. No cloud resources are created by repository checks.

```bash
make check
make terraform
make integration
```

Terraform uses a checked-in provider lockfile and an S3 backend with locking. The [example inputs](terraform/terraform.tfvars.example) contain deliberate placeholders. They are not deployable until replaced with your environment's identities.

