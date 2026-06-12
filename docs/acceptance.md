# Production acceptance record

Record environment, account/region, source commit, AMI, Kafka/JDK/provider versions, operator, date and evidence links. Mark each gate pass/fail/unverified. Do not substitute Terraform success or a green CI badge for these live AWS checks.

## Infrastructure gate

Verify three real AZs, instance placement, no public node addresses, no inbound SSH, mandatory IMDSv2, encrypted root/data EBS, deletion guards, per-node IAM and private DNS. Confirm S3 public access blocking/versioning and that nodes cannot read another node's secret or runtime object.

## Bootstrap gate

Confirm each pinned AMI includes required tooling and SSM Agent, every EBS serial matches its declared volume, services run as `kafka`, expected UUIDs are mounted, and initial bootstrap succeeds from the private subnet. Test a reboot and recovery from a delayed EBS attachment. Re-running unchanged provisioning must preserve cluster identity and data.

## Kafka gate

Require three healthy quorum voters, zero follower lag, all brokers registered and zero under-replicated/unavailable/under-minimum-ISR partitions. Run the roundtrip tool with the real private client route. Test rejected unknown-CA certificates, rejected incorrect hostnames and denied operations for a trusted principal without ACLs.

