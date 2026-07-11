# Jellyfin

Jellyfin with a Tailscale sidecar (`jellyfin-ts`) for tailnet access.

## How it's wired

- The `jellyfin` container runs with `network_mode: service:tailscale`, so it
  shares the sidecar's network namespace. Because of that, the
  `${JELLYFIN_PORT}:8096` LAN port mapping lives on the `tailscale` service,
  not on `jellyfin`.
- `ts-serve.json` is mounted into the sidecar as its `TS_SERVE_CONFIG`:
  Tailscale serve terminates HTTPS on 443 and proxies to
  `localhost:8096`. Tailnet clients use `https://jelly.<tailnet>.ts.net`;
  LAN clients can still hit the host directly on `${JELLYFIN_PORT}`.
- `TS_AUTH_KEY` (in `.env` / `.env.sops`) is only needed for the first
  login — node state persists in the `jellyfin-ts` volume. The node is
  tagged `tag:containers`.
- Intel QuickSync hardware transcoding: `/dev/dri` is passed through and the
  container joins group `44` (`video`).
