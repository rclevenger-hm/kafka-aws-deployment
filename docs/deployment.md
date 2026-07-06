# Deployment

## Prerequisites

Use a dedicated AWS account/environment, AWS CLI v2 with short-lived operator credentials, Terraform 1.12.2, Python 3.9+ and OpenSSL. The deployment identity must manage the resources in this module and pass the created instance profiles to EC2. Keep infrastructure privileges separate from node runtime roles and human Session Manager access.

Select three standard AZs with the chosen x86_64 Nitro instance types available. Confirm quotas for six instances, EBS capacity/IOPS, three EIPs/NAT gateways, nine interface endpoint ENIs, IAM roles and private DNS. Configure a private client and collector path. Review [capacity and cost](capacity-planning.md).

## Pin the machine image

Resolve an Amazon Linux 2023 standard x86_64 AMI in your chosen region, review its release and pin the returned ID in `ami_id`:

```bash
aws ssm get-parameter --region us-east-1 \
  --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
  --query Parameter.Value --output text
```

The module checks Amazon ownership, image ID, AL2023 standard name, x86_64 and HVM. It does not follow the moving parameter automatically. Verify AWS CLI v2, Python 3 and a running SSM Agent in a canary image before cluster rollout. Machine-image changes require the explicit replacement runbook because `prevent_destroy` blocks implicit replacement.

## State and authentication

Authenticate with an approved AWS SSO profile or workload identity. Create a versioned, encrypted, private S3 state bucket outside this module, using a unique key per environment. Restrict state and lockfile access to deployment operators. Set `use_lockfile = true` and leave locking enabled. Configure the backend region separately if the state bucket is elsewhere.

Copy `terraform/backend.hcl.example` to `terraform/backend.hcl`. State includes operational metadata and references but no TLS payloads. It still requires access protection and tested recovery. After test initialization with `-backend=false`, reinitialize with `-reconfigure` for deployment.

## Prepare TLS identities

Each node needs exactly `CN=<node-name>`, its advertised FQDN in DNS SAN, both serverAuth and clientAuth usages, and an unencrypted PKCS8 key. Use your organizational CA in production. Node JSON bundles contain PEM string fields `certificate`, `private_key` and `ca`.

For a disposable lab only:

```bash
python3 tools/lab_pki.py --out pki --prefix kafka --domain kafka.internal --brokers 3
```

The generator refuses overwrite and issues 30-day certificates. Keep `ca.key` offline and retain the admin identity on an authorized operator host. Upload only each node's JSON to its own existing Secrets Manager secret. For one node:

```bash
aws secretsmanager create-secret --region us-east-1 \
  --name kafka-broker-1-tls \
  --secret-string file://pki/kafka-broker-1.json \
  --query '{arn:ARN,version_id:VersionId}' --output json
```

Repeat for all six default nodes. Put the returned ARN/version ID pairs in `tls_secrets`, keyed by exact node name. Never put PEM payloads into Terraform inputs. The module requires all configured nodes and unique secret ARNs. Runtime roles can read their own secret; the configured immutable version ID selects its content. Include `secret_kms_key_arns` if the secrets use customer-managed KMS keys, and authorize those roles in the keys' policies.

## Plan and apply

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
cp terraform/backend.hcl.example terraform/backend.hcl
# Edit both files: AMI, zones, secret references, allowlists and state bucket.
terraform -chdir=terraform init -reconfigure -backend-config=backend.hcl
terraform -chdir=terraform plan -out=deployment.tfplan
terraform -chdir=terraform apply deployment.tfplan
terraform -chdir=terraform output
```

Review the saved plan for intended account/region, three zones, no public node IPs, narrow ingress, encrypted protected storage and correct per-node secrets. Initial bootstrap waits up to five minutes for the separately attached EBS disk. Terraform success alone is not Kafka readiness.

## Inspect startup

Use the `session_commands` output with the Session Manager plugin installed. Human IAM must grant the intended session access; this module grants node connectivity only. On the node:

```bash
sudo cloud-init status --long
sudo journalctl -u cloud-final -u kafka --since '-30 minutes'
sudo systemctl status kafka
sudo findmnt /var/lib/kafka
```

If the initial download or attachment timed out, inspect the cause and retry `sudo kafka-refresh`. A changed installed runtime intentionally requires the [rolling procedure](runbooks/rolling-upgrade.md). Do not print secret bundles or include them in diagnostic logs.

## Establish readiness

From a private client host with Kafka binaries, resolve all advertised broker names. Copy [client.properties.example](../config/client.properties.example) into a protected file with absolute certificate paths, then run:

```bash
python3 tools/health.py --bootstrap BROKER_ENDPOINTS --config /secure/client.properties
python3 tools/smoke.py --bootstrap BROKER_ENDPOINTS --config /secure/client.properties
```

The smoke tool creates a uniquely named RF3 topic, verifies its exact payload and removes only that topic. Complete [acceptance](acceptance.md), install collectors and grant application ACLs before admitting traffic.
