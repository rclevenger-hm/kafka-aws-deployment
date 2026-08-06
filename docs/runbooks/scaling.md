# Broker scaling

## Add capacity

Create a unique TLS secret for every new broker name before increasing `broker_count`. Inspect the resulting plan: existing nodes retain IDs, disks and addresses; new brokers receive the next IDs and rotate across the three zones. Runtime superuser manifests also change to include the new peer principals.

Stage and roll the updated peer-principal manifests across existing nodes before relying on the added brokers. New nodes may retry registration until existing peers recognize their principal. A staged production expansion must coordinate this trust step and new-node startup; do not treat a single apply as the full scaling procedure.

## Reassign replicas

Adding EC2 instances does not move Kafka partitions. Generate an explicit reassignment plan with rack-aware placement and bounded throttles. Review topic impact, peak traffic and spare EBS/network capacity. Execute with Kafka's reassignment tool and wait for completion, full ISR and acceptable client p99 before removing throttles.

## Remove capacity

Move every replica off the broker, verify zero assigned partitions and fence the retiring process. Update operational inventories and TLS access. Reducing `broker_count` is blocked by storage/compute destruction guards until a reviewed retirement change is made. Preserve needed recovery data and remove only the intended resources.

