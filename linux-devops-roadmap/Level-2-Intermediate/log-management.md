# Log Management

View logs:
- tail -f /var/log/syslog  (Debian/Ubuntu)
- tail -f /var/log/messages (RHEL/Amazon Linux)
- journalctl -u <service> -f

Use logrotate for automated rotation (see Level 3).
