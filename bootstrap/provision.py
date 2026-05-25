#!/usr/bin/env python3
"""Provision one private Kafka node. No cloud credentials or TLS payloads in state."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import pwd
import re
import shutil
import subprocess
import tarfile
import tempfile
import time
import urllib.error
import urllib.request

JMX_URL = "https://github.com/prometheus/jmx_exporter/releases/download/1.1.0/jmx_prometheus_javaagent-1.1.0.jar"
JMX_SHA256 = "2d158db7a4cd2999f40ca30a2532bc8456ca3ecf37498cbe60a02a588bf3c9f1"


def run(*args, **kwargs):
    return subprocess.run(args, check=True, text=True, timeout=300, **kwargs)


def atomic_write(path, value, mode=0o640):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temp = tempfile.mkstemp(dir=path.parent)
    try:
        with os.fdopen(fd, "w") as stream:
            stream.write(value)
            stream.flush()
            os.fsync(stream.fileno())
        os.chmod(temp, mode)
        os.replace(temp, path)
    finally:
        if os.path.exists(temp):
            os.unlink(temp)


def request(url, headers=None):
    for attempt in range(5):
        try:
            req = urllib.request.Request(url, headers=headers or {})
            with urllib.request.urlopen(req, timeout=30) as response:
                return response.read()
        except OSError:
            if attempt == 4:
                raise
            time.sleep(2 ** attempt)


def secret_payload(arn, version, region):
    if not re.fullmatch(r"[a-z]{2}-[a-z]+-[0-9]+", region):
        raise ValueError("Invalid AWS region")
    if not re.fullmatch(r"arn:aws:secretsmanager:" + re.escape(region) + r":[0-9]{12}:secret:[A-Za-z0-9/_+=.@-]+", arn):
        raise ValueError("Expected a Secrets Manager ARN in this region")
    if not re.fullmatch(r"[A-Za-z0-9-]{32,64}", version):
        raise ValueError("Expected an immutable Secrets Manager version ID")
    result = run("aws", "secretsmanager", "get-secret-value", "--secret-id", arn,
                 "--version-id", version, "--region", region, "--output", "json",
                 "--no-cli-pager", capture_output=True)
    response = json.loads(result.stdout)
    if response.get("VersionId") != version or response.get("ARN") != arn:
        raise ValueError("Secret response does not match the pinned identity")
    return json.loads(response["SecretString"])


