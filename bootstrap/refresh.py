#!/usr/bin/env python3
"""Stage a node-specific S3 runtime and apply it under an exclusive local lock."""
import argparse
import fcntl
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

FILES = {"provision.py", "kafka.service", "kafka.env", "jmx.yml"}


def validate_manifest(manifest):
    if manifest.get("schema_version") != 1 or not isinstance(manifest.get("config"), dict):
        raise ValueError("Unsupported runtime manifest")
    files = manifest.get("files")
    if not isinstance(files, dict) or set(files) != FILES:
        raise ValueError("Unexpected runtime files")
    if not all(isinstance(value, str) and value for value in files.values()):
        raise ValueError("Runtime files must be nonempty text")
    return manifest


def refresh(allow_change=False, version_id=None):
    settings = json.loads(Path("/etc/kafka-bootstrap.json").read_text())
    with open("/run/kafka-refresh.lock", "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        with tempfile.TemporaryDirectory(prefix="kafka-stage-", dir="/opt") as directory:
            stage = Path(directory)
            download = stage / "manifest.json"
            command = ["aws", "s3api", "get-object", "--bucket", settings["bucket"],
                       "--key", settings["key"], "--region", settings["region"],
                       "--no-cli-pager"]
            if version_id:
                command += ["--version-id", version_id]
            subprocess.run([*command, str(download)], check=True, capture_output=True, timeout=120)
            if download.stat().st_size > 4 * 1024 * 1024:
                raise ValueError("Runtime manifest exceeds four MiB")
            manifest = validate_manifest(json.loads(download.read_text()))
            for name, content in manifest["files"].items():
                (stage / name).write_text(content)
            (stage / "config.json").write_text(json.dumps(manifest["config"]))
            args = ["python3", str(stage / "provision.py"), "--config", str(stage / "config.json")]
            if allow_change:
                args.append("--apply-change")
            subprocess.run(args, check=True, timeout=1800)
            active = Path("/opt/kafka-bootstrap")
            active.mkdir(exist_ok=True, mode=0o700)
            for name in [*FILES, "config.json", "manifest.json"]:
                shutil.copyfile(stage / name, active / name)
                os.chmod(active / name, 0o600)


