# Decision: zonal egress and private management

## Context

A three-zone Kafka topology should not depend on one NAT gateway for all bootstrap and management paths. Reducing egress cost can inadvertently introduce a shared failure domain.

## Decision

Create one NAT gateway per AZ and S3 gateway access. Enable SSM, session-message and Secrets Manager interface endpoints in every AZ by default. No public node address or SSH ingress is created.

## Consequences

The default has meaningful hourly networking cost even when Kafka is idle. Endpoint opt-out retains zonal NAT and must be evaluated against measured traffic and resilience needs. Artifact/package downloads still require outbound access; private management endpoints do not create an air-gapped deployment.
