#!/usr/bin/env bash
# install_devops_packages.sh
# Usage: sudo ./install_devops_packages.sh
set -euo pipefail

echo "[INFO] Detecting package manager..."
if command -v yum >/dev/null 2>&1; then
  PM="yum"
elif command -v dnf >/dev/null 2>&1; then
  PM="dnf"
elif command -v apt >/dev/null 2>&1; then
  PM="apt"
else
  echo "[ERROR] No supported package manager found (apt/yum/dnf)."
  exit 1
fi

echo "[INFO] Using package manager: $PM"

if [[ "$PM" == "apt" ]]; then
  sudo apt update && sudo apt upgrade -y
  sudo apt install -y git nginx openjdk-17-jdk
else
  sudo $PM update -y
  sudo $PM install -y git nginx
  # Try Amazon Corretto first (for Amazon Linux), otherwise install openjdk
  if sudo $PM install -y java-17-amazon-corretto >/dev/null 2>&1; then
    echo "[INFO] Installed amazon-corretto."
  else
    sudo $PM install -y java-17-openjdk >/dev/null 2>&1 || true
  fi
fi

# enable and start nginx if systemd exists
if command -v systemctl >/dev/null 2>&1; then
  sudo systemctl enable --now nginx || true
fi

echo "[DONE] Package installation complete. Versions:"
git --version || true
nginx -v 2>/dev/null || true
java -version 2>/dev/null || true
