#!/usr/bin/env bash
# health_check.sh <service-name>
set -euo pipefail
SERVICE="${1:-nginx}"
if systemctl is-active --quiet "$SERVICE"; then
  echo "[OK] $SERVICE is running"
else
  echo "[ALERT] $SERVICE is not active"
  sudo systemctl restart "$SERVICE" || true
fi
