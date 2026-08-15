# Tests and validation

## Local checks

```bash
make check
make terraform
```

Python's standard library test runner covers listener configuration, deny-by-default authorization settings, archive integrity, storage identity, TLS validation, capacity and health parsing. AWS-specific tests cover NVMe volume selection, foreign/partitioned disk refusal, pinned secret responses and runtime manifest file allowlisting. Documentation checks validate local links, Python syntax and dashboard JSON.

Terraform formatting, provider schema validation and mock-provider plan tests need no AWS account. The committed lockfile pins signed provider packages. Mock plans exercise private topology, role identity, encrypted storage, input failures, endpoint options and lifecycle settings. They do not prove that real account quotas, IAM boundaries, networking or AMIs permit a deployment.

## Real Kafka integration

```bash
make integration
```

Requires Java 17, Python 3, OpenSSL, Internet access for checksum-verified artifacts, process creation and loopback sockets. The test creates a disposable CA and starts three controllers plus three brokers with distinct local ports and storage. It verifies mTLS, RF3/minimum-ISR2 roundtrips, denial for a trusted but unauthorized certificate, acknowledged writes while one broker is down, preserved data after recovery and controller leader failover. It terminates only its own processes and removes its temporary data.

The CI job runs on an isolated Ubuntu runner. Allow roughly several minutes and enough RAM for six JVMs. A restricted sandbox that cannot create listening sockets cannot execute this integration; run it on a suitable host or GitHub Actions.

