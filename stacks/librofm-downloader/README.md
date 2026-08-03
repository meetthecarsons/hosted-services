# librofm-downloader

Polls a Libro.fm account directly and downloads new audiobook purchases
straight into the Audiobookshelf library — the audiobook acquisition path
for [planning/audiobook-library.md](../../../../planning/audiobook-library.md)
in the outer repo. Supersedes an earlier Syncthing-based design (phone
Downloads folder → sync → unzip watcher); this container needs no phone
step at all.

Upstream: [burntcookie90/librofm-downloader](https://github.com/burntcookie90/librofm-downloader).

## How it's wired

- The `librofm-downloader` container runs with `network_mode:
  service:tailscale`, so it shares the sidecar's network namespace.
  Because of that, the `${LIBROFM_PORT}:8080` LAN port mapping lives on
  the `tailscale` service, not on `librofm-downloader`.
- `ts-serve.json` is mounted into the sidecar as its `TS_SERVE_CONFIG`:
  Tailscale serve terminates HTTPS on 443 and proxies to `localhost:8080`.
  Tailnet clients use `https://librofm.<tailnet>.ts.net`; LAN clients can
  still hit the host directly on `${LIBROFM_PORT}`.
- `TS_AUTH_KEY` (in `.env` / `.env.sops`) is only needed for the first
  login — node state persists in the `librofm-downloader-ts` volume. The
  node is tagged `tag:containers`.
- `LIBROFM_MEDIA` bind-mounts straight into the Audiobookshelf library
  root (`/mnt/bulk-pool-01/data/media/audiobooks`) — no staging directory.
  The tool creates one folder per book (`PATH_PATTERN`) and skips
  re-downloading a book if its folder already exists.
- `LIBROFM_DATA` holds the tool's own state (`download_history.json`,
  `libro_library.json`) — app state, not media, so it lives on
  `fast-pool-01/appdata` like other stacks' Docker state.

## Web UI

`GET /` shows current config and a manual sync-trigger button; `GET
/update` forces an immediate check (useful right after a purchase, via
webhook or by hand); `GET /history` returns download history as JSON.

## Password quoting

A Libro.fm password containing `$` needs escaping as `$$` in `.env`, or
docker-compose will try to interpret it as a variable reference — see
[upstream issue #161](https://github.com/burntcookie90/librofm-downloader/issues/161).
