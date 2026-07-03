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

