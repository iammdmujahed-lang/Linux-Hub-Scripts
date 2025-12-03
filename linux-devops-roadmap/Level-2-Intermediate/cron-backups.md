#!/usr/bin/env bash
# setup_cron_backup_devops.sh
# Usage: sudo ./setup_cron_backup_devops.sh [src] [dest] [user]
# Defaults: /opt/projects/app1 -> /backup, user=root
set -euo pipefail

SRC="${1:-/opt/projects/app1}"
DEST="${2:-/backup}"
CRON_USER="${3:-root}"

echo "[INFO] Ensuring $DEST exists and owned by $CRON_USER"
sudo mkdir -p "$DEST"
sudo chown "$CRON_USER":"$CRON_USER" "$DEST" || true

BACKUP_CMD="/usr/bin/tar -czf ${DEST}/app_\$(date +%F).tgz -C $(dirname "$SRC") $(basename "$SRC")"

echo "[INFO] Installing cron for $CRON_USER: 0 2 * * * $BACKUP_CMD"
( sudo crontab -l -u "$CRON_USER" 2>/dev/null | grep -v -F "$BACKUP_CMD" || true; echo "0 2 * * * $BACKUP_CMD" ) | sudo crontab -u "$CRON_USER" -
echo "[DONE] Cron job installed. List cron:"
sudo crontab -l -u "$CRON_USER"
