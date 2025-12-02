#!/usr/bin/env bash
# system_info.sh - print common system info
set -euo pipefail
echo "== CPU =="
lscpu || true
echo "== Memory =="
free -h || true
echo "== Disk usage =="
df -h || true
echo "== Block devices =="
lsblk || true
echo "== OS =="
cat /etc/os-release || true
echo "== Kernel =="
uname -a || true
