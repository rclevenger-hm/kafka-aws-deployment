# Recovery

## Establish the failure boundary

Record surviving controller voters, replica ISR, volume identities and recent changes. Fence failed instances before reusing their Kafka node IDs. Stop concurrent automation. A process restart, node replacement, AZ loss and regional disaster require different actions; do not reformat a disk to make a failed startup disappear.

## Same-zone broker replacement

Prefer reattaching the preserved EBS data volume to a replacement in the same AZ with the same node ID, private DNS and expected volume ID. Keep forced detach disabled and confirm the old host cannot return as a duplicate identity. Restore the node from the reviewed manifest, wait for ISR recovery and run a retained-data verification before replacing another node.

If a broker disk is irrecoverable, preserve evidence and rebuild replicas from healthy brokers using a controlled replacement procedure. New storage must be empty and belong to the intended node/cluster. EBS `prevent_destroy` requires explicit operator action; do not broadly remove lifecycle guards or discard state.

## Controller recovery

Keep a majority of controller metadata intact. One failed controller can be repaired with quorum-specific Kafka procedures and its retained identity. Do not initialize a second cluster UUID or format all controllers together. If a majority's metadata is lost, stop and follow the exact Kafka version's supported recovery procedure with an expert review; broker data alone does not reconstruct every metadata state safely.

## AZ recovery

EBS cannot attach across AZs. Restore the original zone, rebuild broker replicas into reviewed replacement capacity, or restore a snapshot into the target AZ with explicit Terraform/identity reconciliation. Cross-zone controller movement is a membership operation, not a variable edit. Verify client DNS and replica rack placement after recovery.

## Backup and remote DR

Independent crash-consistent EBS snapshots are not an atomic Kafka cluster backup. Use a documented, tested strategy for topics, offsets, ACLs, metadata and application ordering. [MirrorMaker2 example](../../config/mirrormaker2.properties.example) is a starting configuration only; no remote cluster or replication service is deployed.

Test DR in an isolated destination and measure retained records, offset translation, RPO/RTO and cutover. Fence the old writers before activating a recovery destination. Avoid dual writers or an untested attempt to merge divergent logs.

## Terraform state recovery

Recover a known-good version from the protected backend and reconcile against actual resource IDs before any apply. Retain cluster/controller UUIDs, volume IDs and runtime object versions. Never initialize fresh state against an existing cluster and accept replacements without reviewing the resulting identity changes.
