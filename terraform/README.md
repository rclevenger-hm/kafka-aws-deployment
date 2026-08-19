# Terraform module

## Inputs and backend

Use Terraform1.12.2 with the checked-in AWS/random provider lockfile. Initialize an existing private S3 backend with `backend.hcl`; state locking uses S3 lockfiles. [Example inputs](terraform.tfvars.example) require a reviewed AL2023 AMI ID and six exact TLS secret references before deployment.

The module creates three AZ subnet pairs, zonal NAT, private endpoints/DNS, six default protected instances and data volumes, runtime S3 objects, IAM, flow logs and alarms. See [deployment](../docs/deployment.md) for the full sequence and external prerequisites.

