# Rolling runtime changes

## Stage a reviewed change

Read Apache's version-specific upgrade notes and test the target Kafka/JDK/configuration in staging. Change Kafka version and SHA512 together; the renderer supports the 4.1 line. Preserve old binaries and secret versions through the rollback window. Kafka metadata feature upgrades and controller membership changes are separate operations.

Run health and smoke tests and record the current cluster identity, source/target versions and per-node S3 `runtime_version` outputs. Apply a reviewed Terraform plan that updates runtime S3 objects only. A normal runtime change must not replace or stop instances or disks. EC2 image/type/user-data changes require a separate one-node replacement plan; lifecycle guards intentionally block automated fleet replacement.

