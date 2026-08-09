# Expand an EBS data volume

## Preconditions

Capture health, disk UUID/serial, `lsblk` output, free space and current size. Confirm the target is the intended broker or controller, and ensure recovery headroom. Schedule one node at a time. Do not combine storage changes with rolling upgrades or replica reassignment.

## Grow the block device

Increase the relevant size input and inspect the plan for in-place EBS modifications only. Role-level inputs affect every volume of that role; use an approved staged configuration when a one-volume canary is needed. Never decrease volume size. Apply the reviewed plan and wait for the AWS volume modification to complete sufficiently for filesystem expansion.

