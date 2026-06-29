# Decision: zonal egress and private management

## Context

A three-zone Kafka topology should not depend on one NAT gateway for all bootstrap and management paths. Reducing egress cost can inadvertently introduce a shared failure domain.

