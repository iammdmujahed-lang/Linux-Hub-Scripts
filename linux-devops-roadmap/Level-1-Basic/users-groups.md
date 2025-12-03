#!/usr/bin/env bash
# create_devops_user_and_group.sh
# Creates group devops_group and user devops_user, adds user to group, prompts to set password.
set -euo pipefail

GROUP="devops_group"
USER="devops_user"

echo "[INFO] Ensure group exists: $GROUP"
if getent group "$GROUP" >/dev/null; then
  echo "[INFO] Group $GROUP already exists."
else
  sudo groupadd "$GROUP"
  echo "[DONE] Group $GROUP created."
fi

echo "[INFO] Ensure user exists: $USER"
if id "$USER" &>/dev/null; then
  echo "[INFO] User $USER already exists."
else
  sudo useradd -m -s /bin/bash -G "$GROUP" "$USER"
  echo "[DONE] User $USER created and added to $GROUP."
  echo
  read -s -p "Enter initial password for $USER (will not echo): " PASS; echo
  if [[ -n "$PASS" ]]; then
    echo "$USER:$PASS" | sudo chpasswd
    echo "[DONE] Password set for $USER."
  else
    echo "[WARN] No password entered. Set password later with: sudo passwd $USER"
  fi
fi

echo "[INFO] Ensure user is in group"
sudo usermod -aG "$GROUP" "$USER" || true

echo "[RESULT] User and group setup complete:"
id "$USER"
getent group "$GROUP"
