#!/usr/bin/env bash
# One-time VPS setup for Saguki. Run as root:
#   sudo bash setup-vps.sh <domain> <ssh-host-github-uses> [ssh-port]
# e.g. sudo bash setup-vps.sh saguki.example.com 203.0.113.5 22
#
# Creates the `saguki` deploy user, /opt/saguki, the systemd unit `saguki.service`,
# a .env with fresh secrets, and an SSH key for GitHub Actions. Prints the values
# to paste into the GitHub repo secrets.
set -euo pipefail
DOMAIN=${1:?domain}; HOST=${2:?ssh host}; PORT=${3:-22}
DOCKER=$(command -v docker) || { echo "Install Docker first: https://docs.docker.com/engine/install/"; exit 1; }
docker compose version >/dev/null || { echo "Docker compose plugin missing"; exit 1; }
command -v rsync >/dev/null || { echo "Install rsync first (apt install rsync)"; exit 1; }
SYSTEMCTL=$(command -v systemctl)

id saguki &>/dev/null || useradd -m -s /bin/bash saguki
usermod -aG docker saguki
mkdir -p /opt/saguki/deploy /opt/saguki/server
chown -R saguki:saguki /opt/saguki

# The deploy user may restart this one service and nothing else.
echo "saguki ALL=(root) NOPASSWD: $SYSTEMCTL restart saguki" > /etc/sudoers.d/saguki
chmod 440 /etc/sudoers.d/saguki
visudo -cf /etc/sudoers.d/saguki >/dev/null

cat > /etc/systemd/system/saguki.service <<EOF
[Unit]
Description=Saguki sync server (docker compose)
Requires=docker.service
After=docker.service network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/saguki/deploy
ExecStart=$DOCKER compose --profile vps up -d --build --remove-orphans
ExecStop=$DOCKER compose --profile vps down
TimeoutStartSec=900

[Install]
WantedBy=multi-user.target
EOF
$SYSTEMCTL daemon-reload
$SYSTEMCTL enable saguki >/dev/null

ENV=/opt/saguki/deploy/.env
if [ ! -f "$ENV" ]; then
  SAGUKI_PASSWORD=$(openssl rand -base64 18 | tr -d '/+=')
  cat > "$ENV" <<EOF
DOMAIN=$DOMAIN
DB_PASSWORD=$(openssl rand -base64 24 | tr -d '/+=')
SAGUKI_PASSWORD=$SAGUKI_PASSWORD
EOF
  chown saguki:saguki "$ENV"; chmod 600 "$ENV"
  echo; echo "App password (enter this in the apps): $SAGUKI_PASSWORD"
fi

# Fresh key pair just for GitHub Actions; the private half is shown once, then deleted.
KEY=$(mktemp -u)
ssh-keygen -q -t ed25519 -N "" -C "github-actions-saguki" -f "$KEY"
install -d -m 700 -o saguki -g saguki /home/saguki/.ssh
cat "$KEY.pub" >> /home/saguki/.ssh/authorized_keys
chown saguki:saguki /home/saguki/.ssh/authorized_keys; chmod 600 /home/saguki/.ssh/authorized_keys

[ "$PORT" = 22 ] && KH="$HOST" || KH="[$HOST]:$PORT"
echo
echo "=== Add these as GitHub repo secrets (Settings → Secrets and variables → Actions) ==="
echo "VPS_HOST:  $HOST"
echo "VPS_PORT:  $PORT"
echo "VPS_USER:  saguki"
echo "VPS_KNOWN_HOSTS:"
for f in /etc/ssh/ssh_host_*_key.pub; do echo "$KH $(cut -d' ' -f1,2 "$f")"; done
echo "VPS_SSH_KEY:"
cat "$KEY"
shred -u "$KEY" 2>/dev/null || rm -f "$KEY"; rm -f "$KEY.pub"
echo "=== Then push to main (or run the Deploy workflow by hand) to start Saguki. ==="
