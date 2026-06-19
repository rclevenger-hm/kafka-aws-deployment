# Architecture

## Failure domains

Three dedicated controllers use stable IDs 100–102 and independent directory UUIDs. Brokers begin at ID 1, spread round-robin across three standard availability zones. Each node has one private address and DNS name, one role-specific security group, one instance profile and one persistent gp3 volume. EBS volumes are zonal; moving one into another AZ requires a snapshot restore or replica rebuild.

Kafka uses dynamic KRaft quorum bootstrap addresses and an explicit initial voter set. The cluster and controller directory UUIDs are retained in Terraform state. Losing state and generating new UUIDs is not a recovery procedure. Dedicated controllers isolate metadata work from broker heap and disk pressure.

## Network paths

| Port | Destination | Allowed source | Authentication |
|---|---|---|---|
| 9092 | Brokers | Explicit private client CIDRs | Client certificate plus Kafka ACL |
| 9093 | Controllers | Broker and controller security groups | Peer mTLS |
| 9094 | Brokers | Broker and controller security groups | Peer mTLS |
| 9404 | Both roles | Explicit private collector CIDRs | Network allowlist; HTTP metrics |
| 443 | AWS interface endpoints | Node security groups | Instance-profile IAM |

No inbound SSH rule, public IP or Kafka load balancer exists. Brokers advertise their own private DNS names. Route 53 VPC association covers the created VPC; peered or on-premises clients need their own reviewed DNS and routing integration.

## Storage and identity

The bootstrap matches the expected EBS volume ID against the Nitro NVMe serial. It rejects ambiguous, partitioned, incorrectly mounted or non-NVMe devices. Only a disk with no detected signatures is formatted; existing ext4 filesystems are mounted by UUID. Kafka metadata must match both cluster and node IDs, and partial or nonempty unformatted storage is refused.

EC2 and EBS resources have `prevent_destroy`; EC2 API termination protection is also enabled. Attachments prohibit forced detachment. These guards require an explicit reviewed code change for replacement or teardown. They do not replace backups, replication or account access controls.

## Runtime lifecycle

Terraform stores source and nonsecret configuration in one versioned S3 object per node. EC2 user data installs a small refresh entry point and loads that object at initial boot. Running Kafka is not automatically rolled when an S3 object changes. `kafka-refresh` stages a manifest under a local lock; a changed fingerprint requires `--apply-change` on that node.

The service starts on subsequent boots using its installed files and UUID mount. S3, Secrets Manager and the artifact CDN are required for provisioning or refreshing, not for every service restart. The [rolling runbook](runbooks/rolling-upgrade.md) requires external Kafka health gates between nodes.

