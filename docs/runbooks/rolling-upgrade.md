# Rolling runtime changes

## Stage a reviewed change

Read Apache's version-specific upgrade notes and test the target Kafka/JDK/configuration in staging. Change Kafka version and SHA512 together; the renderer supports the 4.1 line. Preserve old binaries and secret versions through the rollback window. Kafka metadata feature upgrades and controller membership changes are separate operations.

Run health and smoke tests and record the current cluster identity, source/target versions and per-node S3 `runtime_version` outputs. Apply a reviewed Terraform plan that updates runtime S3 objects only. A normal runtime change must not replace or stop instances or disks. EC2 image/type/user-data changes require a separate one-node replacement plan; lifecycle guards intentionally block automated fleet replacement.

## Apply one node

Connect with Session Manager. `sudo kafka-refresh` downloads and validates the latest manifest but refuses a changed installed fingerprint before modifying the service. With external health still green, explicitly run:

```bash
sudo kafka-refresh --apply-change
sudo systemctl status kafka
sudo journalctl -u kafka --since '-10 minutes'
```

The command takes a nonblocking local lock, validates secret identity, storage, checksums and TLS, then restarts only that node. Wait for healthy quorum, full ISR and a successful smoke test before another node. Follow the Kafka release's controller/broker ordering guidance. Never restart a controller majority together.

## Roll back

Stop on new offline partitions, increasing quorum lag, sustained client failures or missing replicas. Revert desired runtime inputs and apply the reviewed S3-only plan. If the target release supports downgrade and no incompatible feature level has been finalized, refresh the affected node with `--apply-change`.

For a previously recorded S3 object version, use `sudo kafka-refresh --apply-change --version-id RECORDED_VERSION` on that node only, then reconcile Terraform's desired source. A historical manifest still references its exact TLS version and Kafka checksum. It cannot undo incompatible on-disk formats, changed quorum membership or finalized feature levels.

## Image and instance replacement

Retain the node's EBS disk, IP/DNS, Kafka ID and cluster identity. Drain/fence one node and remove the compute destruction guard only in a reviewed temporary change. Keep forced EBS detach disabled. Confirm the planned replacement is restricted to that node and keep other nodes healthy. Restore the guard after replacement. Practice this in staging before relying on it for patching.
