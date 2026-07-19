# Certificate and CA rotation

## Same-CA leaf rotation

Issue a new certificate with the same exact node CN and advertised DNS SAN, both serverAuth/clientAuth usages and sufficient lifetime. Verify the private key matches. Upload a new version with `aws secretsmanager put-secret-value --secret-id ARN --secret-string file://protected-node.json`, record its returned VersionId, and update that node's `tls_secrets` reference.

Apply the reviewed runtime-object plan, then follow [rolling changes](rolling-upgrade.md) one node at a time. Verify peer and client authentication before continuing. Keep the previous version available for rollback; secret-level IAM permits versions of the same secret while the manifest selects one exact ID.

