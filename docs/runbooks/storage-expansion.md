# Expand an EBS data volume

## Preconditions

Capture health, disk UUID/serial, `lsblk` output, free space and current size. Confirm the target is the intended broker or controller, and ensure recovery headroom. Schedule one node at a time. Do not combine storage changes with rolling upgrades or replica reassignment.

