#!/bin/bash
set -euo pipefail

CONF="/etc/logrotate.d/myapp"
TMP="/tmp/myapp_logrotate.conf"

cat > "$TMP" <<'EOF'
/var/log/myapp.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
}
EOF

# move into place as root, set safe perms
sudo mv "$TMP" "$CONF"
sudo chown root:root "$CONF"
sudo chmod 0644 "$CONF"

echo "Logrotate config written to: $CONF"
echo
echo "Showing file:"
sudo cat "$CONF"
echo
echo "Performing dry-run of logrotate (will NOT actually rotate):"
# Use main logrotate.conf so included d/ files are processed
sudo logrotate -d /etc/logrotate.conf || true

echo
echo "If you want to force-rotate now (will rotate), run:"
echo "  sudo logrotate -f /etc/logrotate.conf"
