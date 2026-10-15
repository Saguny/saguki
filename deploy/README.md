# Deploy to the VPS

The server runs as the systemd service `saguki`, which wraps `docker compose`. Every push to `main` that touches `server/` or `deploy/` triggers GitHub Actions (`.github/workflows/deploy.yml`). The workflow copies the files to `/opt/saguki` over SSH, builds, runs `systemctl restart saguki`, and checks `/health`.

## One-time setup

You need:
- a VPS with **Docker** (including the compose plugin), **rsync** and **nginx** installed
- a DNS **A record** pointing your domain at the VPS

The API listens on `127.0.0.1:8787` (`API_PORT` in `.env`), and nginx serves it publicly. On a VPS with no web server at all, you can use the bundled Caddy instead: add `--profile caddy` to the `docker compose` commands in the systemd unit and the workflow.

1. Upload `deploy/setup-vps.sh` to the VPS, for example with Termius SFTP, and run:
   ```bash
   sudo bash setup-vps.sh saguki.example.com <vps-ip-or-host> [ssh-port]
   ```
   It prints the **app password**, which is what you'll enter in the apps. It also prints five values for GitHub.
2. In GitHub, go to **Settings → Secrets and variables → Actions** and add `VPS_HOST`, `VPS_PORT`, `VPS_USER`, `VPS_KNOWN_HOSTS` and `VPS_SSH_KEY`, exactly as printed.
3. Push to `main`, or go to **Actions → Deploy server → Run workflow**.
4. Install the nginx site and get its HTTPS certificate (the full commands are at the top of `deploy/nginx-saguki.conf`):
   ```bash
   sudo cp /opt/saguki/deploy/nginx-saguki.conf /etc/nginx/sites-available/saguki
   sudo ln -s /etc/nginx/sites-available/saguki /etc/nginx/sites-enabled/saguki
   sudo nginx -t && sudo systemctl reload nginx
   sudo certbot --nginx -d saguki.off-by-one.digital
   ```
5. In each app, tap the cloud icon on Today, enter `https://saguki.example.com` and the app password, then tap Connect.

## Day to day
| | |
|---|---|
| Status / logs | `systemctl status saguki` · `cd /opt/saguki/deploy && docker compose logs -f api` |
| Restart by hand | `sudo systemctl restart saguki` |
| Backups | `/opt/saguki/deploy/backups/`, nightly, kept for 14 days |
| Restore a backup | `gunzip -c backups/saguki-DATE.sql.gz \| docker compose exec -T db psql -U saguki saguki` |
| Revoke a device | `docker compose exec db psql -U saguki saguki -c "DELETE FROM devices WHERE name LIKE 'android%'"` |
| End-to-end check from your PC | `bash server/test/smoke.sh https://saguki.example.com <app password>` |

## Profile pictures (Cloudflare R2)

The app sends a 256 px PNG to `POST /avatar`. The server uploads it to R2 as
`$R2_PREFIX<sha256>.png` and gives back `$R2_PUBLIC_URL/$R2_PREFIX<sha256>.png`.
Until it's set up, uploads return 503 and the app falls back to an emoji or initial.

1. In Cloudflare, go to R2 → Manage API tokens → Create token. Give it **Object Read & Write**, limited to the bucket.
2. On the VPS, add `R2_ACCOUNT_ID`, `R2_TOKEN` (or `R2_ACCESS_KEY_ID` + `R2_SECRET_ACCESS_KEY`), `R2_BUCKET` and `R2_PUBLIC_URL` to `/opt/saguki/deploy/.env` (see `.env.example`), then run `sudo systemctl restart saguki`.
