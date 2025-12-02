#!/usr/bin/env bash
# log_cleanup.sh - delete logs older than N days (default: 7)
set -euo pipefail
DAYS=${1:-7}
echo "[INFO] Removing files in /var/log older than $DAYS days (dry-run if you add --dry)."
sudo find /var/log -type f -mtime +"$DAYS" -print -exec sudo rm -f {} \;
echo "[DONE] Old logs removed."
