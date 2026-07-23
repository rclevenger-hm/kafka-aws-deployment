# Decommission

## Prepare

Confirm application owners have stopped writes and migrated consumers. Complete required retention/export and a tested recovery record. Identify the correct AWS account, region, Terraform state and cluster UUID. Inventory snapshots, TLS secrets, monitoring, DNS, external ACLs and dependencies.

## Remove guarded resources

Disable EC2 API termination protection only for the intended retired nodes and review that change. Compute, EBS data volumes and the runtime bucket separately use `prevent_destroy`; remove those guards only in a reviewed retirement commit. Versioned runtime/state buckets can contain historical objects that require explicit retention decisions. Do not enable blanket force deletion to get past a failed destroy.

Run and review a destroy plan against the correct backend. Detach storage gracefully with nodes stopped. Retain required snapshots and state versions outside the destroyed resources. Track NAT gateways, EIPs and interface endpoints until their deletion is confirmed to avoid ongoing charges.

## Close access

Revoke retired client and operator access, remove obsolete secret versions according to retention policy, and retire collectors/alerts after shutdown is confirmed. The state bucket and pre-existing secrets/SNS topics are external to this module; manage their retention separately. Record the completion and final recovery location without including private keys.
