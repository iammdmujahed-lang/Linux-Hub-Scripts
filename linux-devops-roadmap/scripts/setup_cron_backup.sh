#!/usr/bin/env bash
# setup_cron_backup.sh
# Installs a daily cronjob for backups (2:00 AM). Run as root or with sudo.
set -euo pipefail

BACKUP_CMD='/usr/bin/tar -czf /backup/app_$(date +%F).tgz /opt/app'
CRON_EXPR="0 2 * * * $BACKUP_CMD"

# ensure /backup exists
sudo mkdir -p /backup
sudo chown "$(whoami)" /backup

# install into current user's crontab
( crontab -l 2>/dev/null | grep -v -F "$BACKUP_CMD" || true; echo "$CRON_EXPR" ) | crontab -
echo "[DONE] Installed cron backup for user $(whoami)."
