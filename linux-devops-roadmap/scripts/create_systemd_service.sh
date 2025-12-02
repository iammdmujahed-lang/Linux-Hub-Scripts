#!/usr/bin/env bash
# create_systemd_service.sh <service-name> <exec-cmd> <user> <workdir>
set -euo pipefail
if [[ $# -lt 4 ]]; then
  echo "Usage: $0 <service-name> <exec-cmd> <user> <workdir>"
  echo "Example: $0 myapp '/usr/bin/java -jar /opt/myapp/app.jar' devuser /opt/myapp"
  exit 1
fi
SERVICE_NAME="$1"
EXEC_CMD="$2"
USER="$3"
WORKDIR="$4"

UNIT_PATH="/etc/systemd/system/${SERVICE_NAME}.service"

sudo bash -c "cat > ${UNIT_PATH}" <<EOF
[Unit]
Description=${SERVICE_NAME}
After=network.target

[Service]
User=${USER}
WorkingDirectory=${WORKDIR}
ExecStart=${EXEC_CMD}
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
