#!/usr/bin/env bash
# setup_users.sh
# Creates a sample dev user and group. Edit variables below as needed.
set -euo pipefail

USERNAME="devuser"
GROUPNAME="devteam"
PASSWORD_PLACEHOLDER="ChangeMe123!"  # recommended to change interactively

if id "$USERNAME" &>/dev/null; then
  echo "[INFO] User $USERNAME exists. Skipping creation."
else
  echo "[INFO] Creating user $USERNAME"
  sudo useradd -m -s /bin/bash "$USERNAME"
  echo "$USERNAME:${PASSWORD_PLACEHOLDER}" | sudo chpasswd
fi

if getent group "$GROUPNAME" >/dev/null; then
  echo "[INFO] Group $GROUPNAME exists. Skipping creation."
else
  echo "[INFO] Creating group $GROUPNAME"
  sudo groupadd "$GROUPNAME"
fi

echo "[INFO] Adding $USERNAME to $GROUPNAME"
sudo usermod -aG "$GROUPNAME" "$USERNAME"

echo "[DONE] Created/verified user and group. Please change password and review."
