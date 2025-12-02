#!/usr/bin/env bash
# restart_service.sh <service-name>
set -euo pipefail
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <service-name>"
  exit 1
fi
SERVICE="$1"
sudo systemctl restart "$SERVICE"
sudo systemctl status "$SERVICE" --no-pager
