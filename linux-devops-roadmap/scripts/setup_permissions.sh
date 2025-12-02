#!/usr/bin/env bash
# setup_permissions.sh
# Usage: sudo ./setup_permissions.sh /opt/projects/app1 devteam
set -euo pipefail
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <path> <group>"
  exit 1
fi
TARGET_DIR="$1"
GROUP="$2"

sudo mkdir -p "$TARGET_DIR"
sudo chown -R :"$GROUP" "$TARGET_DIR"
sudo chmod -R 2770 "$TARGET_DIR"   # r+w+x for owner+group, SGID set
echo "[DONE] Created $TARGET_DIR with group $GROUP and permissions 2770"
