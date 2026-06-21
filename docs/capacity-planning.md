# Capacity and cost planning

## Measure the workload

Record peak ingress MiB/s, retention, partition count, compression, compaction overhead, skew, p99 latency target, growth and recovery objectives. Defaults are examples, not a throughput guarantee. Compare required disk and network rates with the selected instance's EBS/network limits as well as the gp3 volume limits.

```bash
python3 tools/capacity.py --ingress-mib-s 5 --retention-hours 72 \
  --brokers 3 --utilization 0.65 --recovery-mib-s 50
```

The calculator reports replicated storage with overhead, steady-state per-broker usage, failure headroom and rebuild time. Reserved rebuild bandwidth must remain available alongside production traffic. RF3 cannot be restored on only two remaining brokers; three-broker clusters need replacement capacity after permanent loss.

