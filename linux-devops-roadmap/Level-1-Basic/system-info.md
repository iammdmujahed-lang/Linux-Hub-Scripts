#!/usr/bin/env bash
# system_info_devops.sh
# Usage: ./system_info_devops.sh
set -euo pipefail

echo "=== CPU ==="
lscpu || true
echo
echo "=== Memory ==="
free -h || true
echo
echo "=== Disk usage ==="
df -h || true
echo
echo "=== Block devices ==="
lsblk || true
echo
echo "=== OS ==="
cat /etc/os-release || true
echo
echo "=== Kernel ==="
uname -a || true
