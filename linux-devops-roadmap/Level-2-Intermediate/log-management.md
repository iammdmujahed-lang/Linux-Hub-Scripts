#!/usr/bin/env bash
# log_cleanup_devops.sh
# Usage: sudo ./log_cleanup_devops.sh [days]
set -euo pipefail

DAYS="${1:-7}"
echo "[INFO] Deleting log files older than $DAYS days in /var/log (will print then delete)."
sudo find /var/log -type f -mtime +"$DAYS" -print -exec sudo rm -f {} \;
echo "[DONE] Old logs removed."
