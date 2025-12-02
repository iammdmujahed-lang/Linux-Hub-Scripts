#!/usr/bin/env bash
# bootstrap_devops_repo.sh
# Creates linux-devops-roadmap, docs, and executable scripts for each topic.
# Optionally clones a remote repo (SSH/HTTPS) or initializes local git and optionally pushes.
#
# Usage:
#   ./bootstrap_devops_repo.sh                    # init local repo only
#   ./bootstrap_devops_repo.sh --remote <URL>    # clone remote or add remote and push
#   ./bootstrap_devops_repo.sh --help            # show help
#
# Designed to run on Amazon Linux / RHEL / Ubuntu / Debian
set -euo pipefail

# ---------- Configuration ----------
ROOT_DIR="${PWD}/linux-devops-roadmap"
SCRIPTS_DIR="${ROOT_DIR}/scripts"
REMOTE_URL=""
GIT_BRANCH="main"
COMMIT_MSG="chore: initial commit - linux devops roadmap and scripts"

# ---------- Helper functions ----------
info(){ printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn(){ printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
err(){ printf "\033[1;31m[ERROR]\033[0m %s\n" "$*"; }
die(){ err "$*"; exit 1; }

usage(){
cat <<'EOF'
bootstrap_devops_repo.sh

Creates a linux-devops-roadmap repo structure, .md docs and executable scripts.

Options:
  --remote <git-url>   Optional. SSH/HTTPS repo URL to push changes to.
  --branch <branch>    Optional. Branch to push (default: main).
  --help               Show this help.
EOF
}

# parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --remote) shift; REMOTE_URL="$1"; shift;;
    --branch) shift; GIT_BRANCH="$1"; shift;;
    --help) usage; exit 0;;
    *) die "Unknown arg: $1";;
  esac
done

# ---------- Prepare workspace ----------
info "Creating root directory: $ROOT_DIR"
mkdir -p "$ROOT_DIR"
mkdir -p "$SCRIPTS_DIR"

# ---------- Create README.md ----------
cat > "$ROOT_DIR/README.md" <<'EOF'
# 🚀 Linux DevOps Roadmap & Automation Guide

This repository contains a practical roadmap and executable helper scripts for Linux Server Setup and DevOps automation.

Levels:
- Level 1 — Basic Linux Administration
- Level 2 — Intermediate DevOps Tasks
- Level 3 — Advanced Production Linux
- linux-commands-cheatsheet — quick commands

Open any file under the folders to view notes; execute scripts in the `scripts/` folder to perform actions (read script comments before running).

Linux families (major server flavours):
- Debian family: Debian, Ubuntu, Linux Mint
- Red Hat family: RHEL, CentOS Stream, Fedora, AlmaLinux, Rocky, Amazon Linux
- SUSE: openSUSE, SLES
- Arch: Arch Linux, Manjaro
- Alpine, Gentoo, and specialized distributions exist too.

EOF

# ---------- LEVEL-1: BASIC (docs + scripts) ----------
mkdir -p "$ROOT_DIR/Level-1-Basic"

cat > "$ROOT_DIR/Level-1-Basic/users-groups.md" <<'EOF'
# User & Group Management

Commands & examples for creating users and groups:
- Create user:
  sudo useradd devuser
  sudo passwd devuser

- Create group:
  sudo groupadd devteam

- Add user to group:
  sudo usermod -aG devteam devuser

- Verify:
  id devuser
  groups devuser

- Delete user/group:
  sudo userdel devuser
  sudo groupdel devteam
EOF

# executable: setup_users.sh
cat > "${SCRIPTS_DIR}/setup_users.sh" <<'EOF'
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
EOF

chmod +x "${SCRIPTS_DIR}/setup_users.sh"


cat > "$ROOT_DIR/Level-1-Basic/permissions.md" <<'EOF'
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
EOF

# executable: setup_permissions.sh
cat > "${SCRIPTS_DIR}/setup_permissions.sh" <<'EOF'
#!/usr/bin/env bash
# setup_permissions.sh
# Usage: sudo ./setup_permissions.sh /opt/projects/app1 devteam
set -euo pipefail
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <path> <group>"
  exit 1
fi
TARGET_DIR="$1"
GROUP="$2"

sudo mkdir -p "$TARGET_DIR"
sudo chown -R :"$GROUP" "$TARGET_DIR"
sudo chmod -R 2770 "$TARGET_DIR"   # r+w+x for owner+group, SGID set
echo "[DONE] Created $TARGET_DIR with group $GROUP and permissions 2770"
EOF

chmod +x "${SCRIPTS_DIR}/setup_permissions.sh"


cat > "$ROOT_DIR/Level-1-Basic/package-management.md" <<'EOF'
# Package Management: install git, nginx, java

Examples:
- Debian/Ubuntu:
  sudo apt update && sudo apt upgrade -y
  sudo apt install -y git nginx openjdk-17-jdk

- RHEL/CentOS/Amazon Linux:
  sudo yum update -y
  sudo yum install -y git nginx
  # Amazon Linux Corretto (java)
  sudo yum install -y java-17-amazon-corretto
EOF

# executable: install_packages.sh
cat > "${SCRIPTS_DIR}/install_packages.sh" <<'EOF'
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
EOF

chmod +x "${SCRIPTS_DIR}/install_packages.sh"


cat > "$ROOT_DIR/Level-1-Basic/system-info.md" <<'EOF'
# System Information

Useful commands:
- lscpu
- free -h
- df -h
- lsblk
- cat /etc/os-release
- uname -a
EOF

# executable: system_info.sh
cat > "${SCRIPTS_DIR}/system_info.sh" <<'EOF'
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
EOF

chmod +x "${SCRIPTS_DIR}/system_info.sh"

# ---------- LEVEL-2: INTERMEDIATE ----------
mkdir -p "$ROOT_DIR/Level-2-Intermediate"

cat > "$ROOT_DIR/Level-2-Intermediate/cron-backups.md" <<'EOF'
# Cron Backups

Example cron (edit paths as needed):
0 2 * * * /usr/bin/tar -czf /backup/app_$(date +\%F).tgz /opt/app
EOF

# executable: setup_cron_backup.sh
cat > "${SCRIPTS_DIR}/setup_cron_backup.sh" <<'EOF'
#!/usr/bin/env bash
# setup_cron_backup.sh
# Installs a daily cronjob for backups (2:00 AM). Run as root or with sudo.
set -euo pipefail

BACKUP_CMD='/usr/bin/tar -czf /backup/app_$(date +%F).tgz /opt/app'
CRON_EXPR="0 2 * * * $BACKUP_CMD"

# ensure /backup exists
sudo mkdir -p /backup
sudo chown "$(whoami)" /backup

# install into current user's crontab
( crontab -l 2>/dev/null | grep -v -F "$BACKUP_CMD" || true; echo "$CRON_EXPR" ) | crontab -
echo "[DONE] Installed cron backup for user $(whoami)."
EOF

chmod +x "${SCRIPTS_DIR}/setup_cron_backup.sh"


cat > "$ROOT_DIR/Level-2-Intermediate/automation-scripts.md" <<'EOF'
# Shell Automation Scripts

- Log cleanup
- Service restart
- Health checks
See scripts/ for executable versions.
EOF

# executable: scripts/log_cleanup.sh
cat > "${SCRIPTS_DIR}/log_cleanup.sh" <<'EOF'
#!/usr/bin/env bash
# log_cleanup.sh - delete logs older than N days (default: 7)
set -euo pipefail
DAYS=${1:-7}
echo "[INFO] Removing files in /var/log older than $DAYS days (dry-run if you add --dry)."
sudo find /var/log -type f -mtime +"$DAYS" -print -exec sudo rm -f {} \;
echo "[DONE] Old logs removed."
EOF
chmod +x "${SCRIPTS_DIR}/log_cleanup.sh"

# executable: scripts/restart_service.sh
cat > "${SCRIPTS_DIR}/restart_service.sh" <<'EOF'
#!/usr/bin/env bash
# restart_service.sh <service-name>
set -euo pipefail
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <service-name>"
  exit 1
fi
SERVICE="$1"
sudo systemctl restart "$SERVICE"
sudo systemctl status "$SERVICE" --no-pager
EOF
chmod +x "${SCRIPTS_DIR}/restart_service.sh"

# executable: scripts/health_check.sh
cat > "${SCRIPTS_DIR}/health_check.sh" <<'EOF'
#!/usr/bin/env bash
# health_check.sh <service-name>
set -euo pipefail
SERVICE="${1:-nginx}"
if systemctl is-active --quiet "$SERVICE"; then
  echo "[OK] $SERVICE is running"
else
  echo "[ALERT] $SERVICE is not active"
  sudo systemctl restart "$SERVICE" || true
fi
EOF
chmod +x "${SCRIPTS_DIR}/health_check.sh"


cat > "$ROOT_DIR/Level-2-Intermediate/log-management.md" <<'EOF'
# Log Management

View logs:
- tail -f /var/log/syslog  (Debian/Ubuntu)
- tail -f /var/log/messages (RHEL/Amazon Linux)
- journalctl -u <service> -f

Use logrotate for automated rotation (see Level 3).
EOF

cat > "$ROOT_DIR/Level-2-Intermediate/monitoring-performance.md" <<'EOF'
# Monitoring & Troubleshooting

Commands:
- top, htop
- free -h, vmstat 1
- iftop, ip -s link
- journalctl -u <service> --since "15 minutes ago"
EOF

# ---------- LEVEL-3: ADVANCED ----------
mkdir -p "$ROOT_DIR/Level-3-Advanced"

cat > "$ROOT_DIR/Level-3-Advanced/systemd-service.md" <<'EOF'
# Custom systemd Service

Example unit file: /etc/systemd/system/myapp.service

[Unit]
Description=My App
After=network.target

[Service]
User=devuser
WorkingDirectory=/opt/myapp
ExecStart=/usr/bin/java -jar /opt/myapp/app.jar
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# executable: create_systemd_service.sh
cat > "${SCRIPTS_DIR}/create_systemd_service.sh" <<'EOF'
#!/usr/bin/env bash
# create_systemd_service.sh <service-name> <exec-cmd> <user> <workdir>
set -euo pipefail
if [[ $# -lt 4 ]]; then
  echo "Usage: $0 <service-name> <exec-cmd> <user> <workdir>"
  echo "Example: $0 myapp '/usr/bin/java -jar /opt/myapp/app.jar' devuser /opt/myapp"
  exit 1
fi
SERVICE_NAME="$1"
EXEC_CMD="$2"
USER="$3"
WORKDIR="$4"

UNIT_PATH="/etc/systemd/system/${SERVICE_NAME}.service"

sudo bash -c "cat > ${UNIT_PATH}" <<EOF
[Unit]
Description=${SERVICE_NAME}
After=network.target

[Service]
User=${USER}
WorkingDirectory=${WORKDIR}
ExecStart=${EXEC_CMD}
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now "${SERVICE_NAME}"
sudo systemctl status "${SERVICE_NAME}" --no-pager
EOF
chmod +x "${SCRIPTS_DIR}/create_systemd_service.sh"


cat > "$ROOT_DIR/Level-3-Advanced/ssh-hardening.md" <<'EOF'
# SSH Hardening

Recommendations:
- PermitRootLogin no
- PasswordAuthentication no
- AllowUsers <list>

Edit /etc/ssh/sshd_config and restart sshd:
sudo systemctl restart sshd
EOF

# executable: ssh_hardening.sh
cat > "${SCRIPTS_DIR}/ssh_hardening.sh" <<'EOF'
#!/usr/bin/env bash
# ssh_hardening.sh - modifies key sshd settings (requires sudo)
set -euo pipefail
SSHD_CONF="/etc/ssh/sshd_config"
BACKUP="${SSHD_CONF}.bak.$(date +%F_%T)"
sudo cp "$SSHD_CONF" "$BACKUP"
echo "[INFO] Backed up $SSHD_CONF -> $BACKUP"

# apply settings (this will set/replace these keys)
sudo sed -i -E 's/^#?PermitRootLogin.*/PermitRootLogin no/' "$SSHD_CONF"
sudo sed -i -E 's/^#?PasswordAuthentication.*/PasswordAuthentication no/' "$SSHD_CONF"
# keep PAM as-is, ensure UsePAM yes
sudo sed -i -E 's/^#?UsePAM.*/UsePAM yes/' "$SSHD_CONF"

echo "[INFO] Please ensure you have an SSH key for at least one user in /home/<user>/.ssh/authorized_keys"
sudo systemctl restart sshd
echo "[DONE] sshd restarted. If you lose access, restore from backup: sudo cp $BACKUP $SSHD_CONF && sudo systemctl restart sshd"
EOF
chmod +x "${SCRIPTS_DIR}/ssh_hardening.sh"


cat > "$ROOT_DIR/Level-3-Advanced/lvm-setup.md" <<'EOF'
# LVM Setup

Flow:
1. pvcreate /dev/xvdb
2. vgcreate appvg /dev/xvdb
3. lvcreate -L 10G -n applv appvg
4. mkfs.ext4 /dev/appvg/applv
5. mount /dev/appvg/applv /mnt/appdata

Be careful: pvcreate will erase data on the device.
EOF

# executable: lvm_setup.sh
cat > "${SCRIPTS_DIR}/lvm_setup.sh" <<'EOF'
#!/usr/bin/env bash
# lvm_setup.sh <device> <vgname> <lvname> <size> <mountpoint>
# Example: sudo ./lvm_setup.sh /dev/xvdb appvg applv 10G /mnt/appdata
set -euo pipefail
if [[ $# -lt 5 ]]; then
  echo "Usage: $0 <device> <vgname> <lvname> <size> <mountpoint>"
  exit 1
fi
DEVICE="$1"
VG="$2"
LV="$3"
SIZE="$4"
MOUNTPOINT="$5"

read -p "WARNING: pvcreate will erase $DEVICE. Continue? (yes/NO): " CONF
if [[ "$CONF" != "yes" ]]; then
  echo "Aborted by user."
  exit 1
fi

sudo pvcreate "$DEVICE"
sudo vgcreate "$VG" "$DEVICE"
sudo lvcreate -L "$SIZE" -n "$LV" "$VG"
sudo mkfs.ext4 "/dev/${VG}/${LV}"
sudo mkdir -p "$MOUNTPOINT"
sudo mount "/dev/${VG}/${LV}" "$MOUNTPOINT"
echo "[DONE] Mounted /dev/${VG}/${LV} -> ${MOUNTPOINT}"
EOF
chmod +x "${SCRIPTS_DIR}/lvm_setup.sh"


cat > "$ROOT_DIR/Level-3-Advanced/firewall-rules.md" <<'EOF'
# Firewall rules

Examples:
- UFW (Ubuntu): sudo ufw enable; sudo ufw allow 22; sudo ufw allow 80
- firewalld (RHEL/Amazon Linux): sudo firewall-cmd --permanent --add-port=8080/tcp; sudo firewall-cmd --reload
EOF

# executable: setup_firewall.sh
cat > "${SCRIPTS_DIR}/setup_firewall.sh" <<'EOF'
#!/usr/bin/env bash
# setup_firewall.sh - enable basic firewall rules
set -euo pipefail

if command -v ufw >/dev/null 2>&1; then
  echo "[INFO] Configuring UFW"
  sudo ufw enable || true
  sudo ufw allow 22
  sudo ufw allow 80
  sudo ufw allow 443
  sudo ufw status
elif command -v firewall-cmd >/dev/null 2>&1; then
  echo "[INFO] Configuring firewalld"
  sudo systemctl enable --now firewalld
  sudo firewall-cmd --permanent --add-port=22/tcp
  sudo firewall-cmd --permanent --add-port=80/tcp
  sudo firewall-cmd --permanent --add-port=443/tcp
  sudo firewall-cmd --reload
  sudo firewall-cmd --list-all
else
  echo "[WARN] No recognized firewall manager found. Install ufw or firewalld first."
  exit 1
fi
EOF
chmod +x "${SCRIPTS_DIR}/setup_firewall.sh"


cat > "$ROOT_DIR/Level-3-Advanced/logrotate.md" <<'EOF'
# Logrotate

Example config at /etc/logrotate.d/myapp:
/opt/myapp/logs/*.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    copytruncate
}
EOF

# executable: setup_logrotate.sh
cat > "${SCRIPTS_DIR}/setup_logrotate.sh" <<'EOF'
#!/usr/bin/env bash
# setup_logrotate.sh <app-log-dir> (creates /etc/logrotate.d/myapp)
set -euo pipefail
APP_LOG_DIR="${1:-/opt/myapp/logs}"
CONF_PATH="/etc/logrotate.d/myapp"

sudo mkdir -p "$APP_LOG_DIR"
sudo tee "$CONF_PATH" > /dev/null <<EOF
${APP_LOG_DIR}/*.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    copytruncate
}
EOF

echo "[DONE] Created $CONF_PATH for $APP_LOG_DIR"
sudo logrotate -d "$CONF_PATH" || true
EOF
chmod +x "${SCRIPTS_DIR}/setup_logrotate.sh"

# ---------- linux-commands-cheatsheet ----------
CHEATS_DIR="$ROOT_DIR/linux-commands-cheatsheet"
mkdir -p "$CHEATS_DIR"

cat > "$CHEATS_DIR/file-dirs.md" <<'EOF'
# File & Directory Commands
ls -l
ls -lh
cd /path
pwd
mkdir -p dirname
rm file
rm -rf folder
cp file1 file2
mv file1 file2
EOF

cat > "$CHEATS_DIR/networking.md" <<'EOF'
# Networking Commands
ip a
ifconfig
ping google.com
ss -tulnp
curl http://localhost
wget URL
EOF

cat > "$CHEATS_DIR/process-management.md" <<'EOF'
# Process Management
ps aux
top
htop
kill PID
kill -9 PID
systemctl status <service>
systemctl restart <service>
EOF

cat > "$CHEATS_DIR/permissions.md" <<'EOF'
# Permissions & ACLs
chmod 755 file
chmod -R 770 dir
chown user:group file
setfacl -m u:user:rwx file
getfacl file
EOF

cat > "$CHEATS_DIR/storage-commands.md" <<'EOF'
# Storage Commands
df -h
du -sh *
lsblk
fdisk -l
mount /dev/xvdb1 /mnt
umount /mnt
blkid
EOF

cat > "$CHEATS_DIR/system-commands.md" <<'EOF'
# System Commands
hostname
uptime
uname -a
cat /etc/os-release
free -h
journalctl -xe
EOF

# ---------- Initialize Git and push (optional) ----------
cd "$ROOT_DIR"
if [[ -n "${REMOTE_URL:-}" ]]; then
  info "REMOTE_URL provided: $REMOTE_URL"
  # If remote exists, attempt to clone into a temp dir and copy over? Simpler: initialize local and set remote.
fi

if [ -d ".git" ]; then
  info "Git already initialized in $ROOT_DIR (skipping git init)."
else
  git init
  git checkout -b "$GIT_BRANCH" || true
fi

git add .
git commit -m "$COMMIT_MSG" || true

if [[ -n "${REMOTE_URL}" ]]; then
  # set or update origin remote
  if git remote get-url origin &>/dev/null; then
    git remote set-url origin "$REMOTE_URL"
  else
    git remote add origin "$REMOTE_URL"
  fi
  info "Pushing to remote $REMOTE_URL (branch: $GIT_BRANCH)"
  git push -u origin "$GIT_BRANCH"
  info "Push complete."
else
  warn "No remote provided. Repository initialized locally at: $ROOT_DIR"
fi

info "All files & scripts created. Scripts are in: $SCRIPTS_DIR"
info "Make sure to inspect scripts before executing destructive operations (LVM, ssh hardening, logrotate)."
info "Example: cd $ROOT_DIR && ./scripts/install_packages.sh"

exit 0

