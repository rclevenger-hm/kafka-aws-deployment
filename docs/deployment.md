# Deployment

## Prerequisites

Use a dedicated AWS account/environment, AWS CLI v2 with short-lived operator credentials, Terraform 1.12.2, Python 3.9+ and OpenSSL. The deployment identity must manage the resources in this module and pass the created instance profiles to EC2. Keep infrastructure privileges separate from node runtime roles and human Session Manager access.

Select three standard AZs with the chosen x86_64 Nitro instance types available. Confirm quotas for six instances, EBS capacity/IOPS, three EIPs/NAT gateways, nine interface endpoint ENIs, IAM roles and private DNS. Configure a private client and collector path. Review [capacity and cost](capacity-planning.md).

