#!/usr/bin/env bash
# restart_service_devops.sh
# Usage: sudo ./restart_service_devops.sh <service>
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <service>"
  exit 1
fi
SERVICE="$1"
sudo systemctl restart "$SERVICE"
sudo systemctl status "$SERVICE" --no-pager
