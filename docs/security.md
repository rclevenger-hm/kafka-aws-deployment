# Security model

## Trust boundaries

Deployment operators can change infrastructure and executable S3 runtime content. Treat their IAM permissions as root-equivalent for Kafka nodes. Node profiles have read-only access to their own manifest and TLS secret, plus the AWS managed SSM core policy. They cannot read another node's configured secret or write runtime objects. The SSM policy includes service-required wildcard resources; do not mistake it for a Kafka administration grant.

Human Session Manager permissions, identity federation, MFA and session logging policies belong to the account's access-management system. Session access with sudo is privileged host access. IMDSv2 and hop limit 1 reduce metadata exposure but do not prevent a privileged local process from using the node role.

