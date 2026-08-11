# Expand an EBS data volume

## Preconditions

Capture health, disk UUID/serial, `lsblk` output, free space and current size. Confirm the target is the intended broker or controller, and ensure recovery headroom. Schedule one node at a time. Do not combine storage changes with rolling upgrades or replica reassignment.

## Grow the block device

Increase the relevant size input and inspect the plan for in-place EBS modifications only. Role-level inputs affect every volume of that role; use an approved staged configuration when a one-volume canary is needed. Never decrease volume size. Apply the reviewed plan and wait for the AWS volume modification to complete sufficiently for filesystem expansion.

## Grow ext4

On the node, resolve the volume using its EBS serial and verify the mounted filesystem UUID with `findmnt /var/lib/kafka`. This deployment uses a whole unpartitioned ext4 data volume, so no partition resize is expected. After confirming the device, run `sudo resize2fs /dev/CONFIRMED_NVME_DEVICE`. Do not copy a device number from another host: enumeration order is not stable.

Verify `df -h /var/lib/kafka`, `lsblk`, filesystem errors, Kafka health and the roundtrip tool. Record before/after sizes. Increasing EBS capacity does not automatically grow ext4; bootstrap intentionally avoids modifying an existing filesystem's size.

## Performance changes

Change gp3 IOPS/throughput independently of capacity within the validated limits. Compare effective performance with the instance's EBS ceiling and workload p99. Keep restoration and normal traffic within measured spare capacity.
