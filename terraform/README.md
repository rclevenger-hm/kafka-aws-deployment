# Terraform module

## Inputs and backend

Use Terraform1.12.2 with the checked-in AWS/random provider lockfile. Initialize an existing private S3 backend with `backend.hcl`; state locking uses S3 lockfiles. [Example inputs](terraform.tfvars.example) require a reviewed AL2023 AMI ID and six exact TLS secret references before deployment.

The module creates three AZ subnet pairs, zonal NAT, private endpoints/DNS, six default protected instances and data volumes, runtime S3 objects, IAM, flow logs and alarms. See [deployment](../docs/deployment.md) for the full sequence and external prerequisites.

## Important defaults

| Input | Default | Meaning |
|---|---|---|
| region/zones | us-east-1 / a,b,c | Verify availability in your account |
| broker_count | 3 | Range3–18; reassignment remains manual |
| broker/controller instance | m6i.xlarge / m6i.large | x86_64 Nitro, benchmark first |
| broker/controller disk | 500 /50 GiB | Encrypted separate gp3 |
| broker IOPS/throughput | 3000 /125 MiB/s | Bounded performance inputs |
| client/metrics CIDRs | Empty | Inbound access closed |
| private endpoints/flow logs | Enabled | Review ongoing costs |
| deletion protection | Enabled | Additional lifecycle guards are unconditional |
| Kafka | 4.1.2 +SHA512 | Change version and digest together |

## Validation

```bash
terraform fmt -check -recursive
terraform init -backend=false -input=false -lockfile=readonly
terraform validate
terraform test
```

Mock plans do not create AWS resources. A real deployment requires reinitialization with the correct backend. Avoid targeted plans as a general rollout strategy; review a complete plan and use the documented one-node runtime/replacement procedures.

## Lifecycle

Source/configuration changes update versioned S3 objects without changing instance user data. Use [rolling changes](../docs/runbooks/rolling-upgrade.md) to activate them. AMI/type/user-data changes may require instance replacement and are deliberately blocked by `prevent_destroy` until a reviewed maintenance change. EBS and runtime bucket deletion are separately guarded.

Outputs include private bootstrap servers, cluster/node identities, volume IDs, runtime version IDs, subnets, security groups and Session Manager commands. No TLS payload is output or read into state.
