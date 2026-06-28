# Decision: separate desired runtime from restarts

## Context

Updating EC2 user data can replace or stop instances. A fleet-wide runtime change must not implicitly restart a controller majority or several brokers.

## Decision

Keep a small initial bootstrap in user data and store each node's desired source/config in a versioned S3 object. An explicit refresh runs under a local lock and rejects changed fingerprints without the operator's one-node `--apply-change` action. AMI/instance/user-data replacements remain blocked by compute destruction guards.

## Consequences

Terraform convergence and Kafka rollout are separate gates. S3 write permission is privileged executable-code access. Operators retain object/secret versions for supported rollback and verify external Kafka health after each refresh. A local file lock does not coordinate maintenance across different nodes; that remains an operator responsibility.
