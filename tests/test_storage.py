import tempfile
from pathlib import Path
import unittest
from helpers import config, provision
class StorageTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(); self.root = Path(self.temp.name)
    def tearDown(self): self.temp.cleanup()
    def identity(self, folder, cluster="cluster", node=1):
        path = self.root / folder; path.mkdir(exist_ok=True)
        (path / "meta.properties").write_text(f"# Kafka metadata\ncluster.id={cluster}\nnode.id={node}\nversion=1\n")
    def test_fresh_empty_disk_can_format(self):
        self.assertFalse(provision.verify_identity(self.root, "cluster", 1))
    def test_repeat_uses_existing_identity(self):
        self.identity("data"); self.identity("metadata")
        self.assertTrue(provision.verify_identity(self.root, "cluster", 1))
    def test_foreign_cluster_is_rejected(self):
        self.identity("data", "foreign"); self.identity("metadata", "foreign")
        with self.assertRaises(ValueError): provision.verify_identity(self.root, "cluster", 1)
    def test_foreign_node_is_rejected(self):
        self.identity("data", node=2); self.identity("metadata", node=2)
        with self.assertRaises(ValueError): provision.verify_identity(self.root, "cluster", 1)
    def test_partial_format_is_rejected(self):
        self.identity("metadata")
        with self.assertRaises(ValueError): provision.verify_identity(self.root, "cluster", 1)
    def test_nonempty_unformatted_disk_is_rejected(self):
        (self.root / "data").mkdir(); (self.root / "data" / "partition.log").write_text("valuable")
        with self.assertRaises(ValueError): provision.verify_identity(self.root, "cluster", 1)
    def test_atomic_write_permissions(self):
        path = self.root / "secret"
        provision.atomic_write(path, "first", 0o600); provision.atomic_write(path, "second", 0o600)
        self.assertEqual(path.read_text(), "second")
        self.assertEqual(path.stat().st_mode & 0o777, 0o600)


class StorageFormatTests(unittest.TestCase):
    def test_cluster_ids_are_attached_to_option_for_both_roles(self):
        for role in ("controller", "broker"):
            for cluster in ("AAAAAAAAAAAAAAAAAAAAAA", "-41-R1JMTYCsMaDkAghfqg", "_41-R1JMTYCsMaDkAghfqg"):
                with self.subTest(role=role, cluster=cluster):
                    c = config(role); c["cluster_id"] = cluster
                    provision.validate_config(c)
                    expected = ["/opt/kafka/bin/kafka-storage.sh", "format", "--cluster-id=" + cluster,
                                "--config", "/etc/kafka/server.properties"]
                    expected += ["--initial-controllers", c["initial_controllers"]] if role == "controller" else ["--no-initial-controllers"]
                    self.assertEqual(provision.storage_format_command(c), expected)

    def test_local_runtime_and_config_paths_are_separate_arguments(self):
        c = config("controller")
        command = provision.storage_format_command(c, Path("/tmp/kafka runtime"), Path("/tmp/node config/server.properties"))
        self.assertEqual(command[0], "/tmp/kafka runtime/bin/kafka-storage.sh")
        self.assertEqual(command[4], "/tmp/node config/server.properties")
        self.assertEqual(command[-2:], ["--initial-controllers", c["initial_controllers"]])
