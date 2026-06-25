# Decision: self-managed Kafka on EC2

## Context

The OCI and GCP references describe infrastructure and operating behavior under direct operator control. AWS parity therefore requires visible node identities, storage and runtime configuration.

## Decision

Use dedicated EC2 controllers/brokers and Terraform-managed networking/identity/storage. Amazon MSK is a valid managed alternative, but adopting it would change the responsibility and configuration model. Compare it separately for a production service decision.

## Consequences

Operators own JDK/Kafka patching, certificates, backups, scaling, quorum procedures and availability testing. The repo supplies automation and tests, not an operational SLA. See [acceptance](../acceptance.md).
