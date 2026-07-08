# Failure exercises

## Preparation

Use an isolated staging cluster with representative traffic and an approved recovery window. Capture healthy quorum/ISR, client SLOs and disk identity. Stop if another maintenance event or existing replication issue is present. Never remove two controllers at once.

## Broker outage

Stop Kafka on one broker, retaining its EBS volume. Confirm RF3 topics continue acknowledged writes with two in-sync replicas, and alerts report reduced replication. Restart, wait for complete ISR recovery, then verify exact retained payloads. Measure recovery under normal traffic rather than an idle cluster.

## Controller leader loss

Identify the active controller, stop only its Kafka service, and verify a new leader is elected from the remaining majority. Confirm metadata operations and application traffic recover within the target SLO. Restart the original controller and wait for all three voters with zero lag.

