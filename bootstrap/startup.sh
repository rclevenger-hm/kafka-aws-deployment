#!/usr/bin/env bash
set -euo pipefail
umask 077
# Standard Amazon Linux 2023 includes AWS CLI v2 and SSM Agent.
command -v aws >/dev/null
command -v python3 >/dev/null
install -d -m 0700 /opt/kafka-bootstrap
cat > /etc/kafka-bootstrap.json <<'CONFIG'
{"bucket":"${bucket}","key":"${key}","region":"${region}"}
CONFIG
cat > /usr/local/sbin/kafka-refresh <<'REFRESH'
${refresh_source}
REFRESH
chmod 0700 /usr/local/sbin/kafka-refresh
exec /usr/local/sbin/kafka-refresh
