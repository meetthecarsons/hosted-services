# Recommended Self‑Hosted Services for a Home Lab

This file lists useful services you might run in a home lab, with a short description, deployment notes, and common Docker images. Pick the ones that match your needs and resource constraints.

## Reverse proxy / TLS
- **Traefik** — Dynamic reverse proxy with built‑in ACME (Let's Encrypt). Great for routing many services and automatic TLS.
  - Image: `traefik/traefik:latest`
  - Notes: Use TCP routers for SMTP/TLS fronting; label your containers for routing.
- **Caddy** — Simple automatic TLS web server, easy config.
  - Image: `caddy:latest`

## Authentication / SSO
- **Authelia** — Lightweight authentication portal (2FA) for web services.
  - Image: `authelia/authelia`
- **Keycloak** — Full OpenID Connect / SSO server (heavier).
  - Image: `quay.io/keycloak/keycloak`

## Git / SCM
- **Gitea** — Lightweight Git hosting, issues, CI integrations.
  - Image: `docker.gitea.com/gitea:latest`

## Dashboards / Service Index
- **Homer** — Static homepage/dashboard for service links and status.
  - Image: `b4bz/homer`
  - Notes: Serve static assets from `./assets`; port 8080.

## Notifications / Mail gateways
- **Mailrise** — SMTP → Apprise notifications (matrix, telegram, discord, etc.). Good for device alerts.
  - Image: `yoryan/mailrise`
  - Notes: Mount a single `/etc/mailrise.conf` file; consider TLS offload with Traefik TCP.

## IPAM / DCIM (lighter than NetBox)
- **phpIPAM** — IPAM only, lightweight and easy to run.
  - Image: `phpipam/phpipam`
- **RackTables** — Simple rack/asset tracker if you want DCIM-lite.

## Full DCIM / IPAM
- **NetBox** — Powerful IPAM + DCIM; Django app with Postgres + Redis + RQ workers. Use when you need API-first, relational modeling.
  - Image: `netboxcommunity/netbox`
  - Notes: Run Postgres + Redis; protect `ENCRYPTION_KEY` and `SECRET_KEY`.

## Monitoring & Metrics
- **Prometheus** — Time series metrics collection.
  - Image: `prom/prometheus`
- **Grafana** — Visualization and alerting.
  - Image: `grafana/grafana`
- **Node Exporter** — Host metrics for Prometheus.
  - Image: `prom/node-exporter`
- **Netdata** — Lightweight per‑host monitoring with nice UI (fast setup).
  - Image: `netdata/netdata`

## Logging / Traces
- **Grafana Loki** (log store) + **Promtail** (shipper) — lightweight log stack.
  - Images: `grafana/loki`, `grafana/promtail`

## Secrets / Passwords
- **Vaultwarden (Bitwarden RS)** — Lightweight Bitwarden-compatible server.
  - Image: `vaultwarden/server`
  - Notes: Good for password storage on small infra.

## File sync / Collaboration
- **Nextcloud** — File syncing, calendars, contacts, Collabora/ONLYOFFICE integrations.
  - Image: `nextcloud`
  - Notes: Needs PHP + DB (MariaDB/Postgres), configure external storage and backups.

## Media & Home Entertainment
- **Jellyfin** — Media server (video/audio) for self-hosted streaming.
  - Image: `jellyfin/jellyfin`
- **Radarr / Sonarr / Lidarr** — Automated indexer/download managers.
  - Images: `linuxserver/radarr`, `linuxserver/sonarr`, `linuxserver/lidarr`
- **Transmission / qBittorrent** — Torrent clients (many images, `linuxserver/transmission`, `linuxserver/qbittorrent`).

## Home Automation
- **Home Assistant** — Full home automation platform.
  - Image: `homeassistant/home-assistant`
  - Notes: Integrations for many devices; may need Zigbee/Z‑Wave gateways.

## DNS / Adblocking
- **Pi‑hole** — Network‑wide adblocking and DNS.
  - Image: `pihole/pihole`
- **AdGuard Home** — Modern DNS/Adblocking alternative.
  - Image: `adguard/adguardhome`

## VPN / Remote Access
- **WireGuard** — Lightweight VPN; run via `linuxserver/wireguard` or `ghcr.io/linuxserver/wireguard`.
- **Tailscale** — Zero‑config mesh VPN; runs as an agent (less manual network config).
  - Image: `tailscale/tailscale`

## CI / Runners
- **Drone CI** — Lightweight container native CI.
  - Image: `drone/drone`
- **Gitea Actions / Runners** — Use Gitea with runners or integrate with Drone.

## Package Registries & Build
- **Verdaccio** — npm registry proxy/cache.
  - Image: `verdaccio/verdaccio`
- **Nexus / Harbor** — Container registry / artifact repositories (heavier).

## Backups / Object Storage
- **Restic** — Backup tool (use with rclone, S3, or local storage).
- **MinIO** — S3‑compatible object storage for local testing.
  - Image: `minio/minio`

## Databases (for services)
- **Postgres** — Recommended for NetBox, Gitea (prod), many apps.
  - Image: `postgres:14`
- **MariaDB / MySQL** — Common for php apps like phpIPAM and Nextcloud.
  - Images: `mariadb`, `mysql`

## Lightweight / no-infra options
- Keep a git‑backed inventory in `Gitea` (Markdown/YAML) for very small setups.
- Use single‑file, SQLite or small PHP apps (phpIPAM, RackTables) when you want minimal operational overhead.

---

## How to pick
- If you want low-maintenance, start with: Traefik (reverse proxy), Gitea, Homer, Vaultwarden, Netdata, and phpIPAM.
- If you need automation and API integration, consider NetBox, Prometheus/Grafana, and Loki.
- For media and telemetry, run Jellyfin + Radarr/Sonarr + Transmission alongside Netdata.

## Quick next steps I can do for you
- Add ready‑to‑drop `docker-compose.yml` stacks for any two services above under `stacks/`.
- Generate minimal sample configs for `phpIPAM`, `Mailrise`, or `NetBox`.


---
Generated for your home‑lab inventory. File: `SELF_HOSTED_SERVICES.md`.
