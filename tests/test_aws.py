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


