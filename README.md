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

## Topology

```mermaid
flowchart TB
  Clients["Private applications"] -->|"9092 mTLS"| Brokers["Three or more brokers · three AZs"]
  Brokers -->|"9093 mTLS"| Controllers["Three dedicated controllers · three AZs"]
  Brokers --- Data["Per-node encrypted EBS"]
  Controllers --- Data
  Runtime["Versioned S3 manifests"] --> Brokers
  Runtime --> Controllers
  Secrets["Per-node TLS secrets"] --> Brokers
  Secrets --> Controllers
```

Clients need routing into the VPC and resolution for the private DNS zone. A Session Manager shell provides administration; a single forwarded bootstrap port does not provide a route to every broker's advertised address.

## Operational boundaries

A successful Terraform apply does not establish Kafka readiness. Complete [acceptance](docs/acceptance.md) before admitting traffic. Live AWS provisioning, SSM sessions, EBS attachment/reboot recovery, cross-zone behavior, performance and disaster recovery must be exercised in your account.

Default resources include six EC2 instances, 1,650 GiB of data storage, six boot volumes, three NAT gateways and three interface endpoint services in three zones. Review AWS costs and quotas before applying. Prometheus, Grafana, application networking, organizational PKI, remote DR clusters and human IAM grants are not provisioned.

## Repository map

| Path | Purpose |
|---|---|
| [terraform](terraform/README.md) | AWS infrastructure, validated inputs and mock plans |
| [bootstrap](bootstrap/provision.py) | Guarded runtime, EBS identity and TLS provisioning |
| [tools](tools/health.py) | Health, smoke, capacity and lab certificate utilities |
| [monitoring](monitoring/alerts.yml) | Alert rules, tests, scrape example and dashboard |
| [tests](tests/integration.py) | Unit regressions and real Kafka fault exercises |
| [docs](docs/README.md) | Deployment, security, acceptance and runbooks |

Licensed under [MIT](LICENSE). Contributions follow [CONTRIBUTING.md](CONTRIBUTING.md).
