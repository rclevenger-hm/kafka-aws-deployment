# Failure exercises

## Preparation

Use an isolated staging cluster with representative traffic and an approved recovery window. Capture healthy quorum/ISR, client SLOs and disk identity. Stop if another maintenance event or existing replication issue is present. Never remove two controllers at once.

## Broker outage

Stop Kafka on one broker, retaining its EBS volume. Confirm RF3 topics continue acknowledged writes with two in-sync replicas, and alerts report reduced replication. Restart, wait for complete ISR recovery, then verify exact retained payloads. Measure recovery under normal traffic rather than an idle cluster.

