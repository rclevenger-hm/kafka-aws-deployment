# Daily operations

## Health gate

From an authorized private admin host, run `tools/health.py` with the bootstrap list and protected client properties. It requires an elected controller leader, all three voters, zero follower lag and no unavailable, under-replicated or under-minimum-ISR topics. Use `tools/smoke.py` for a unique-topic exact roundtrip; the admin identity needs topic creation/deletion rights.

