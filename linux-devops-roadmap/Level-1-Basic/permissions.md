#!/usr/bin/env bash
# set_devops_permissions.sh
# Usage: sudo ./set_devops_permissions.sh [target-dir]
# Default target: /opt/projects/app1
set -euo pipefail

TARGET="${1:-/opt/projects/app1}"
GROUP="devops_group"
USER="devops_user"

echo "[INFO] Creating target dir: $TARGET"
sudo mkdir -p "$TARGET"

echo "[INFO] Set owner root:$GROUP"
sudo chown -R root:"$GROUP" "$TARGET"

echo "[INFO] Set permissions to 2770 (rwx owner+group, SGID bit)"
sudo chmod -R 2770 "$TARGET"
sudo chmod g+s "$TARGET"

echo "[INFO] Add user $USER to $GROUP (if not already)"
sudo usermod -aG "$GROUP" "$USER" || true

echo "[DONE] Permissions set. Verify:"
ls -ld "$TARGET"
