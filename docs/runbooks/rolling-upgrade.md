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

