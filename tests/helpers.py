import importlib.util
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
def load(path, name):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module
provision = load("bootstrap/provision.py", "provision")
pki = load("tools/lab_pki.py", "pki")
def config(role="broker"):
    return dict(node_name="kafka-broker-1" if role == "broker" else "kafka-controller-1",
                node_id=1 if role == "broker" else 100, role=role,
                fqdn="kafka-broker-1.kafka.internal" if role == "broker" else "kafka-controller-1.kafka.internal",
                zone="us-east-1a", region="us-east-1", data_volume_id="vol-0123456789abcdef0", cluster_id="AAAAAAAAAAAAAAAAAAAAAA",
                kafka_version="4.1.2", kafka_sha512="a" * 128, retention_hours=168,
                quorum="kafka-controller-1.kafka.internal:9093,kafka-controller-2.kafka.internal:9093,kafka-controller-3.kafka.internal:9093",
                initial_controllers="100@kafka-controller-1.kafka.internal:9093:BBBBBBBBBBBBBBBBBBBBBB",
                super_users="User:CN=kafka-admin;User:CN=kafka-broker-1",
                tls_secret_arn="arn:aws:secretsmanager:us-east-1:123456789012:secret:node-ABCDEF",
                tls_secret_version="11111111-2222-3333-4444-555555555555")
