# Failure exercises

## Preparation

Use an isolated staging cluster with representative traffic and an approved recovery window. Capture healthy quorum/ISR, client SLOs and disk identity. Stop if another maintenance event or existing replication issue is present. Never remove two controllers at once.

## Broker outage

Stop Kafka on one broker, retaining its EBS volume. Confirm RF3 topics continue acknowledged writes with two in-sync replicas, and alerts report reduced replication. Restart, wait for complete ISR recovery, then verify exact retained payloads. Measure recovery under normal traffic rather than an idle cluster.

## Controller leader loss

Identify the active controller, stop only its Kafka service, and verify a new leader is elected from the remaining majority. Confirm metadata operations and application traffic recover within the target SLO. Restart the original controller and wait for all three voters with zero lag.

## Host reboot and attachment delay

Reboot one node through a reviewed change. Verify UUID mounting happens before Kafka starts and that no format occurs. In a disposable replacement test, delay the expected EBS attachment: bootstrap must fail closed and later succeed after the right volume appears. A different volume must never be formatted as a substitute.

## AZ loss

Use your approved AWS fault-injection procedure to isolate one zone. Confirm the remaining two controllers form a majority and correctly placed replicas satisfy ISR2. Observe clients' advertised-address failover, NAT independence and management reachability. Restore the zone and verify full recovery before concluding the exercise.

## Reduced quorum and disk pressure

In a disposable cluster, verify loss of the controller majority or falling below minimum ISR stops unsafe writes. Simulate disk pressure with bounded test data, then exercise capacity alerts and [expansion](runbooks/storage-expansion.md). Never deliberately fill production controller storage.

## DR recovery

Exercise [recovery](runbooks/recovery.md) in an isolated destination. Record retained data range, offsets, ACL restoration, client cutover and prevention of dual writers. Snapshots or replication configurations without a demonstrated restore do not establish an RPO/RTO.
