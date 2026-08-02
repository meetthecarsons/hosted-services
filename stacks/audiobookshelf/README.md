# Audiobookshelf

Audiobookshelf with a Tailscale sidecar (`audiobookshelf-ts`) for tailnet
access, serving both the owner's wife's audiobook library (see
`planning/audiobook-library.md` in the outer repo) and a shared podcast
library (see `planning/podcast-library.md`).

## How it's wired

- The `audiobookshelf` container runs with `network_mode: service:tailscale`,
  so it shares the sidecar's network namespace. Because of that, the
  `${ABS_PORT}:80` LAN port mapping lives on the `tailscale` service, not on
  `audiobookshelf`.
- `ts-serve.json` is mounted into the sidecar as its `TS_SERVE_CONFIG`:
  Tailscale serve terminates HTTPS on 443 and proxies to `localhost:80`.
  Tailnet clients (including the mobile app) use
  `https://audiobooks.<tailnet>.ts.net`; LAN clients can still hit the host
  directly on `${ABS_PORT}`.
- `TS_AUTH_KEY` (in `.env` / `.env.sops`) is only needed for the first
  login — node state persists in the `audiobookshelf-ts` volume. The node
  is tagged `tag:containers`.
- `ABS_AUDIOBOOKS` bind-mounts the library root
  (`/mnt/bulk-pool-01/data/media/audiobooks`), the same path the
  `syncthing` stack's `_incoming` folder lands purchased zips into and
  (eventually) the Listenarr torrent-acquisition path hardlinks into.
- `ABS_PODCASTS` bind-mounts a second library root
  (`/mnt/bulk-pool-01/data/media/podcasts`), added as a separate
  Audiobookshelf library of type Podcast. Unlike audiobooks, nothing
  external populates this path — Audiobookshelf's own scheduler downloads
  new episodes directly from each subscribed show's RSS feed.

## Metadata providers

Audiobookshelf's default metadata providers (Audible, OpenLibrary) need no
API key. Only chase a provider key if match quality on real titles turns
out to be poor — see `planning/audiobook-library.md`'s open questions.
