# Security model

## Trust boundaries

Deployment operators can change infrastructure and executable S3 runtime content. Treat their IAM permissions as root-equivalent for Kafka nodes. Node profiles have read-only access to their own manifest and TLS secret, plus the AWS managed SSM core policy. They cannot read another node's configured secret or write runtime objects. The SSM policy includes service-required wildcard resources; do not mistake it for a Kafka administration grant.

Human Session Manager permissions, identity federation, MFA and session logging policies belong to the account's access-management system. Session access with sudo is privileged host access. IMDSv2 and hop limit 1 reduce metadata exposure but do not prevent a privileged local process from using the node role.

## Network and encryption

Kafka peers and clients use mTLS with hostname verification and private advertised DNS. No listener accepts plaintext Kafka. Client CIDRs and metrics CIDRs default empty. Metrics use private HTTP with an allowlist; deploy a protected collector or authenticated proxy where stronger telemetry transport is required.

EBS boot/data volumes are encrypted. The runtime bucket blocks all public access, requires HTTPS, uses server-side encryption and keeps object versions. Secrets use Secrets Manager encryption; optional customer KMS key access is constrained through the Secrets Manager service. Terraform never reads private-key payloads.

Node egress is intentionally broad through zonal NAT for distribution packages, Apache and GitHub artifacts. VPC endpoints keep supported management calls private. Organizations requiring destination filtering should provide an egress proxy/firewall and approved mirrors, then validate every bootstrap dependency before narrowing egress.

