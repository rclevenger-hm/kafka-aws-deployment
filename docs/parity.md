# AWS, GCP and OCI capability comparison

The reference comparison uses OCI revision `9f2b2b41d36f75a1fe58f040f3f54ddd3d3b02dc` and GCP revision `659565b3f0aef76f9ecc39e23e60c92bc82ddd1c`. These are repository capabilities, not a ranking of cloud services or a production certification.

| Capability | OCI reference | GCP reference | AWS implementation |
|---|---|---|---|
| Terraform network | VCN foundation | VPC/subnet/NAT | VPC, three private/public subnet pairs, zonal NAT |
| Dedicated KRaft compute | Documented target | Three controllers +3+ brokers | Three controllers +3+ brokers |
| Runtime installation | Scaffold | Guarded Python and systemd | Guarded Python and systemd on AL2023 |
| Persistent disks | Operational guidance | Protected persistent SSD | Encrypted protected gp3, explicit IOPS/throughput |
| Disk identity | Guidance | Fixed GCE device + Kafka identity | Expected NVMe EBS serial + Kafka identity |
| Private administration | Guidance | IAP/OS Login | Session Manager, no SSH ingress, IMDSv2 |
| TLS/ACLs | Guidance | Per-node secrets, mTLS, default deny | Per-node pinned Secrets Manager versions, same Kafka policy |
| Runtime staging | Not implemented | Instance metadata | Versioned per-node S3 manifest, local lock and explicit apply |
| Monitoring assets | Operational guidance | JMX, Prometheus, Grafana | Same assets plus EC2 alarms and VPC flow logs |
| Unit and plan tests | Network contract | Runtime and GCP mock plans | Runtime, AWS identity/storage and AWS mock plans |
| Real Kafka tests | Not included | Six processes, TLS, ACL, broker restart | Same baseline plus writes during broker loss and controller leader failover |
| Recovery documentation | Included | Expanded runbooks | AWS-specific recovery, volume expansion and scaling |
| Live-cloud qualification | Not established here | Not established here | Required before production |

Portable runtime, monitoring and test components retain the MIT-licensed reference lineage. AWS adds platform-specific controls and failure coverage while preserving the same Kafka durability/authentication contract. See [acceptance](acceptance.md) for the limits of CI evidence.
