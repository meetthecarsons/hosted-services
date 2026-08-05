# Navidrome

Navidrome with a Tailscale sidecar (`navidrome-ts`) for tailnet access,
serving the owner's wife's Bandcamp purchases as a Spotify-like music
library (see `planning/music-library.md` in the outer repo).

## How it's wired

- The `navidrome` container runs with `network_mode: service:tailscale`, so
  it shares the sidecar's network namespace. Because of that, the
  `${NAVIDROME_PORT}:4533` LAN port mapping lives on the `tailscale`
  service, not on `navidrome`.
- `ts-serve.json` is mounted into the sidecar as its `TS_SERVE_CONFIG`:
  Tailscale serve terminates HTTPS on 443 and proxies to `localhost:4533`.
  Tailnet clients (including Subsonic-compatible mobile apps) use
  `https://music.<tailnet>.ts.net`; LAN clients can still hit the host
  directly on `${NAVIDROME_PORT}`.
- `TS_AUTH_KEY` (in `.env` / `.env.sops`) is only needed for the first
  login — node state persists in the `navidrome-ts` volume. The node is
  tagged `tag:containers`.
- The official image has no `PUID`/`PGID` environment variables; ownership
  is set via the compose `user:` field instead (`2000:2000`, the `apps`
  service user).
- `NAVIDROME_MUSIC` bind-mounts the library root
  (`/mnt/bulk-pool-01/data/media/music`), read-only — the same path the
  `bandcampsync` stack writes new purchases into.

## Clients

Navidrome exposes a Subsonic-compatible API, so any Subsonic client
(Symfonium, DSub, Sonixd, Amperfy, …) works against it without a
Navidrome-specific app.
