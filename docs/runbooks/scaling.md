# Broker scaling

## Add capacity

Create a unique TLS secret for every new broker name before increasing `broker_count`. Inspect the resulting plan: existing nodes retain IDs, disks and addresses; new brokers receive the next IDs and rotate across the three zones. Runtime superuser manifests also change to include the new peer principals.

Stage and roll the updated peer-principal manifests across existing nodes before relying on the added brokers. New nodes may retry registration until existing peers recognize their principal. A staged production expansion must coordinate this trust step and new-node startup; do not treat a single apply as the full scaling procedure.

