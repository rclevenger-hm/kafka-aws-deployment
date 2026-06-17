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

