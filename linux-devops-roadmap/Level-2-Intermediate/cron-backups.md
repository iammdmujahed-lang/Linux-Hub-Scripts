# Cron Backups

Example cron (edit paths as needed):
0 2 * * * /usr/bin/tar -czf /backup/app_$(date +\%F).tgz /opt/app
