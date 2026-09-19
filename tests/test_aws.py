import json
from types import SimpleNamespace
import unittest
from unittest.mock import patch
from helpers import config, load, provision
refresh = load("bootstrap/refresh.py", "refresh")


class EbsTests(unittest.TestCase):
    def disk(self, **values):
        return dict(name="/dev/nvme2n1", serial="vol0123456789abcdef0", type="disk", mountpoint=None, **values)

    def test_volume_identity_survives_enumeration_change(self):
        disks = [dict(name="/dev/nvme0n1", serial="volfffffffffffffffff", type="disk"), self.disk()]
        self.assertEqual(str(provision.select_ebs_device(disks, config()["data_volume_id"])), "/dev/nvme2n1")

    def test_absent_disk_returns_none_without_formatting(self):
        self.assertIsNone(provision.select_ebs_device([], config()["data_volume_id"]))

    def test_hyphenated_serial_is_supported(self):
        disk = self.disk(); disk["serial"] = config()["data_volume_id"]
        self.assertIsNotNone(provision.select_ebs_device([disk], config()["data_volume_id"]))

    def test_duplicate_identity_fails_closed(self):
        with self.assertRaises(ValueError):
            provision.select_ebs_device([self.disk(), self.disk()], config()["data_volume_id"])

    def test_partitioned_volume_is_rejected(self):
        with self.assertRaises(ValueError):
            provision.select_ebs_device([self.disk(children=[{"name": "/dev/nvme2n1p1"}])], config()["data_volume_id"])

    def test_root_or_foreign_mount_is_rejected(self):
        for path in ("/", "/home", "/var/lib/other"):
            disk = self.disk(); disk["mountpoint"] = path
            with self.subTest(path=path), self.assertRaises(ValueError):
                provision.select_ebs_device([disk], config()["data_volume_id"])

    def test_existing_kafka_mount_is_accepted(self):
        disk = self.disk(); disk["mountpoint"] = "/var/lib/kafka"
        self.assertIsNotNone(provision.select_ebs_device([disk], config()["data_volume_id"]))

    def test_device_path_injection_rejected(self):
        disk = self.disk(); disk["name"] = "/dev/nvme2n1;reboot"
        with self.assertRaises(ValueError): provision.select_ebs_device([disk], config()["data_volume_id"])

    def test_invalid_volume_id_rejected(self):
        with self.assertRaises(ValueError): provision.select_ebs_device([], "root")


class SecretsTests(unittest.TestCase):
    def response(self, **changes):
        c = config()
        response = dict(ARN=c["tls_secret_arn"], VersionId=c["tls_secret_version"], SecretString=json.dumps({"certificate": "test"}))
        response.update(changes)
        return SimpleNamespace(stdout=json.dumps(response))

    def fetch(self):
        c = config()
        return provision.secret_payload(c["tls_secret_arn"], c["tls_secret_version"], c["region"])

    def test_exact_version_requested_without_secret_logging(self):
        with patch.object(provision, "run", return_value=self.response()) as run:
            self.assertEqual(self.fetch(), {"certificate": "test"})
            self.assertIn("--version-id", run.call_args.args)
            self.assertIn(config()["tls_secret_version"], run.call_args.args)
            self.assertTrue(run.call_args.kwargs["capture_output"])

    def test_wrong_response_version_rejected(self):
        with patch.object(provision, "run", return_value=self.response(VersionId="different")):
            with self.assertRaises(ValueError): self.fetch()

    def test_wrong_response_secret_rejected(self):
        with patch.object(provision, "run", return_value=self.response(ARN="other")):
            with self.assertRaises(ValueError): self.fetch()

    def test_cross_region_secret_rejected_before_api_call(self):
        c = config()
        with patch.object(provision, "run") as run:
            with self.assertRaises(ValueError): provision.secret_payload(c["tls_secret_arn"], c["tls_secret_version"], "us-west-2")
            run.assert_not_called()

    def test_mutable_stage_and_shell_injection_rejected(self):
        for version in ("AWSCURRENT", "latest", "a" * 32 + ";id"):
            with self.subTest(version=version), self.assertRaises(ValueError):
                provision.secret_payload(config()["tls_secret_arn"], version, "us-east-1")


class ManifestTests(unittest.TestCase):
    def manifest(self):
        return dict(schema_version=1, files={name: "content" for name in refresh.FILES}, config=config())

    def test_expected_manifest_is_accepted(self):
        manifest = self.manifest()
        self.assertEqual(refresh.validate_manifest(manifest), manifest)

    def test_unknown_schema_rejected(self):
        manifest = self.manifest(); manifest["schema_version"] = 2
        with self.assertRaises(ValueError): refresh.validate_manifest(manifest)

    def test_path_traversal_file_rejected(self):
        manifest = self.manifest(); manifest["files"]["../../etc/passwd"] = "bad"
        with self.assertRaises(ValueError): refresh.validate_manifest(manifest)

    def test_missing_file_rejected(self):
        manifest = self.manifest(); del manifest["files"]["kafka.service"]
        with self.assertRaises(ValueError): refresh.validate_manifest(manifest)

    def test_nontext_and_empty_content_rejected(self):
        for value in (None, {}, ""):
            manifest = self.manifest(); manifest["files"]["provision.py"] = value
            with self.subTest(value=value), self.assertRaises(ValueError): refresh.validate_manifest(manifest)
