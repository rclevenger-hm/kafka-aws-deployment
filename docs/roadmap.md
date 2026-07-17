# Roadmap and qualification work

## Account qualification

Complete live AWS acceptance for the pinned AMI, IAM boundaries, private bootstrap, EBS attachment and reboot recovery. Measure workload latency and recovery under AZ failure. Retain the evidence beside deployment records rather than asserting production readiness from mock tests.

## Operational integrations

Integrate organizational PKI renewal, host/certificate collectors, centralized Kafka logs, human Session Manager audit settings and budget alerts. Add a tested DR destination and workload-specific replication/offset policy.

## Further automation

Consider a reviewed rolling orchestrator that acquires a cluster-wide maintenance lease and proves quorum/ISR health before each action. Add destructive recovery tests only in isolated disposable cloud environments with explicit resource budgets. Expand supported Kafka release lines after compatibility and upgrade testing.
