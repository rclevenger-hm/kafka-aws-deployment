# Production acceptance record

Record environment, account/region, source commit, AMI, Kafka/JDK/provider versions, operator, date and evidence links. Mark each gate pass/fail/unverified. Do not substitute Terraform success or a green CI badge for these live AWS checks.

## Infrastructure gate

Verify three real AZs, instance placement, no public node addresses, no inbound SSH, mandatory IMDSv2, encrypted root/data EBS, deletion guards, per-node IAM and private DNS. Confirm S3 public access blocking/versioning and that nodes cannot read another node's secret or runtime object.

## Bootstrap gate

Confirm each pinned AMI includes required tooling and SSM Agent, every EBS serial matches its declared volume, services run as `kafka`, expected UUIDs are mounted, and initial bootstrap succeeds from the private subnet. Test a reboot and recovery from a delayed EBS attachment. Re-running unchanged provisioning must preserve cluster identity and data.

## Kafka gate

Require three healthy quorum voters, zero follower lag, all brokers registered and zero under-replicated/unavailable/under-minimum-ISR partitions. Run the roundtrip tool with the real private client route. Test rejected unknown-CA certificates, rejected incorrect hostnames and denied operations for a trusted principal without ACLs.

## Failure and SLO gate

At representative load, stop one broker, restart the controller leader, reboot one host and isolate one AZ in a controlled environment. Measure availability, client errors/p99, election time, recovery lag and replica placement. Do not assume local-process CI simulates regional or AZ infrastructure failures. Complete [failure exercises](failure-exercises.md).

## Operations gate

Verify alert delivery to the responsible team, host disk/certificate expiry monitoring, rolling runtime updates, secret rotation, state recovery, a disk expansion and tested backup/DR restoration. Record measured RPO/RTO and accepted cost/quotas. Assign ownership for patching, certificates and incident response.

