# Palworld Dedicated Server

[`thijsvanloef/palworld-server-docker`](https://github.com/thijsvanloef/palworld-server-docker),
chosen over a raw SteamCMD install for the same reason as other stacks here:
env-driven config, built-in scheduled backups, and a built-in scheduled
reboot — no custom scripting needed for either.

## How it's wired

- Runs as `PUID`/`PGID` `2000`/`2000` (the `apps` service user), matching
  house convention.
- `AUTO_REBOOT_ENABLED` restarts the server daily at 04:00 (5 min warning
  to any connected players) — Palworld has a known memory leak that grows
  with uptime regardless of player count, so a scheduled reboot is the
  documented mitigation rather than something specific to this deployment.
  `MEM_LIMIT` (compose.yaml's `mem_limit`) is a Docker-level backstop in
  case usage climbs faster than the daily cycle handles — if hit, the
  container gets OOM-killed and `restart: unless-stopped` brings it back.
- `RCON_PORT` is `25576`, not the image's default `25575` — that port is
  already taken by `minecraft-java`'s RCON on the same host.
- `BACKUP_ENABLED` is on by default in the image; `DELETE_OLD_BACKUPS` and
  `OLD_BACKUP_DAYS` are overridden here to prune after 14 days instead of
  the image's default 30, to bound disk use on `${DATA_DIR}`.
- Save data, backups, and generated configs all live under `${DATA_DIR}`
  (mounted at `/palworld/` in the container) — back that path up the same
  way as any other stack's data directory.
- `SERVER_PASSWORD` gates joining; `ADMIN_PASSWORD` doubles as the RCON
  auth password (Palworld's RCON protocol is tied to the admin password,
  there's no separate RCON credential).
- `palworld-exporter` ([`jimmysharp/palworld_exporter`](https://github.com/jimmysharp/palworld_exporter))
  polls `palworld`'s own REST API `/v1/api/metrics` endpoint over the
  stack's internal Docker network and re-exposes it in Prometheus format on
  `EXPORTER_PORT` (default `18212`) — server FPS, frame time, player count,
  uptime. Reuses `ADMIN_PASSWORD` for the REST API's basic auth, no separate
  credential. Not yet scraped by any Prometheus instance — that's a
  separate step on whichever host runs Prometheus.

## Start with

```bash
cd ~/hosted-services/stacks/palworld
sops -d .env.sops > .env
docker compose up -d
rm .env
```

Or via the repo root `Makefile`: `make deploy SERVICE=palworld`.
