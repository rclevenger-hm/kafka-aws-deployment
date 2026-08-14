# Tests and validation

## Local checks

```bash
make check
make terraform
```

Python's standard library test runner covers listener configuration, deny-by-default authorization settings, archive integrity, storage identity, TLS validation, capacity and health parsing. AWS-specific tests cover NVMe volume selection, foreign/partitioned disk refusal, pinned secret responses and runtime manifest file allowlisting. Documentation checks validate local links, Python syntax and dashboard JSON.

Terraform formatting, provider schema validation and mock-provider plan tests need no AWS account. The committed lockfile pins signed provider packages. Mock plans exercise private topology, role identity, encrypted storage, input failures, endpoint options and lifecycle settings. They do not prove that real account quotas, IAM boundaries, networking or AMIs permit a deployment.

