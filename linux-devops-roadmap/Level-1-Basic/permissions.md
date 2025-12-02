# File & Directory Permissions & Ownership

Examples:
- Change owner:
  sudo chown user:group /opt/project

- Permissions:
  chmod 755 file
  chmod -R 770 /opt/project

- Set SGID (so new files inherit group):
  sudo chmod g+s /opt/project

- Sticky bit (shared folders):
  sudo chmod +t /shared-folder
