# Daily operations

## Health gate

From an authorized private admin host, run `tools/health.py` with the bootstrap list and protected client properties. It requires an elected controller leader, all three voters, zero follower lag and no unavailable, under-replicated or under-minimum-ISR topics. Use `tools/smoke.py` for a unique-topic exact roundtrip; the admin identity needs topic creation/deletion rights.

## Node inspection

Use the `session_commands` Terraform output. Inspect `systemctl status kafka`, `journalctl -u kafka`, `findmnt /var/lib/kafka`, `df -h /var/lib/kafka` and EC2/EBS metrics. Confirm the mounted UUID and volume serial before any storage action. Keep keys and secret API responses out of terminal transcripts.

