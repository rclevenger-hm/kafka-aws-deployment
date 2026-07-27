# Recovery

## Establish the failure boundary

Record surviving controller voters, replica ISR, volume identities and recent changes. Fence failed instances before reusing their Kafka node IDs. Stop concurrent automation. A process restart, node replacement, AZ loss and regional disaster require different actions; do not reformat a disk to make a failed startup disappear.

