# Capacity and cost planning

## Measure the workload

Record peak ingress MiB/s, retention, partition count, compression, compaction overhead, skew, p99 latency target, growth and recovery objectives. Defaults are examples, not a throughput guarantee. Compare required disk and network rates with the selected instance's EBS/network limits as well as the gp3 volume limits.

```bash
python3 tools/capacity.py --ingress-mib-s 5 --retention-hours 72 \
  --brokers 3 --utilization 0.65 --recovery-mib-s 50
```

The calculator reports replicated storage with overhead, steady-state per-broker usage, failure headroom and rebuild time. Reserved rebuild bandwidth must remain available alongside production traffic. RF3 cannot be restored on only two remaining brokers; three-broker clusters need replacement capacity after permanent loss.

## Disk and heap

Brokers default to 500 GiB gp3, 3,000 IOPS and 125 MiB/s. Controllers default to 50 GiB gp3. Broker heap is 2 GiB and controller heap 1 GiB; leave capacity for page cache and native memory. Benchmark with realistic record sizes and compression. Raising provisioned gp3 performance beyond the instance's EBS ceiling will not improve end-to-end throughput.

Use [storage expansion](runbooks/storage-expansion.md) before exhaustion. AWS enlarges the block device separately from filesystem growth. The bootstrap intentionally does not shrink or automatically resize an existing filesystem.

