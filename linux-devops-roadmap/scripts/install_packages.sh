#!/usr/bin/env bash
# install_packages.sh
# Installs git, nginx and Java (best-effort for the distro); run as a user with sudo.
set -euo pipefail

# Detect package manager
if command -v apt >/dev/null 2>&1; then
  PM="apt"
elif command -v yum >/dev/null 2>&1; then
  PM="yum"
elif command -v dnf >/dev/null 2>&1; then
  PM="dnf"
else
  echo "[ERROR] Unsupported package manager. Install packages manually."
  exit 1
fi

echo "[INFO] Using package manager: $PM"

if [[ $PM == "apt" ]]; then
  sudo apt update && sudo apt upgrade -y
  sudo apt install -y git nginx openjdk-17-jdk
elif [[ $PM == "yum" || $PM == "dnf" ]]; then
  sudo $PM update -y
  sudo $PM install -y git nginx
  # Try to install Amazon Corretto or openjdk if available
  if sudo $PM install -y java-17-amazon-corretto 2>/dev/null; then
    echo "[INFO] Installed amazon-corretto"
  else
    sudo $PM install -y java-17-openjdk 2>/dev/null || true
  fi
fi

# enable nginx
if command -v systemctl >/dev/null 2>&1; then
  sudo systemctl enable --now nginx || true
fi

echo "[DONE] Package installation completed (check output above)."
