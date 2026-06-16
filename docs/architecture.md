# Architecture

## Failure domains

Three dedicated controllers use stable IDs 100–102 and independent directory UUIDs. Brokers begin at ID 1, spread round-robin across three standard availability zones. Each node has one private address and DNS name, one role-specific security group, one instance profile and one persistent gp3 volume. EBS volumes are zonal; moving one into another AZ requires a snapshot restore or replica rebuild.

Kafka uses dynamic KRaft quorum bootstrap addresses and an explicit initial voter set. The cluster and controller directory UUIDs are retained in Terraform state. Losing state and generating new UUIDs is not a recovery procedure. Dedicated controllers isolate metadata work from broker heap and disk pressure.

