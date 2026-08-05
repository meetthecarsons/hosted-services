# bandcampsync

Polls the owner's wife's Bandcamp account for purchases and downloads
anything new straight into the Navidrome music library (see
`planning/music-library.md` in the outer repo). No web UI and no Tailscale
sidecar — it's a scheduled batch job, not a service to reach remotely.

## How it's wired

- Runs on a daily timer (`RUN_DAILY_AT`, hour of day in the container's
  `TZ`); after each run it sleeps until the next occurrence.
- Authenticates using an exported Bandcamp session cookie, not a stored
  username/password — Bandcamp has no public API, so bandcampsync rides
  along on a real logged-in browser session. Export cookies from a
  logged-in browser (see the [upstream README](https://github.com/meeb/bandcampsync#configuration)
  for the recommended browser-extension method) and place the file as
  `cookies.txt` directly in `BANDCAMPSYNC_CONFIG` on the host
  (`/mnt/fast-pool-01/appdata/bandcampsync/cookies.txt`) — this file is
  never tracked in git and isn't touched by `make deploy`, since it lives
  in the persistent appdata directory, not the repo checkout.
- Sessions expire on their own on an unknown timeline (see
  `planning/music-library.md`'s open questions) — when sync starts failing
  auth, re-export `cookies.txt` the same way.
- Downloads land in `BANDCAMPSYNC_DOWNLOADS`
  (`/mnt/bulk-pool-01/data/media/music`, the same path the `navidrome`
  stack's `NAVIDROME_MUSIC` mounts read-only) as `Artist Name/Album Name/`
  folders — Navidrome picks them up on its own scan schedule, no separate
  import step.
- A checkpoint file (`.bandcampsync-state.json`) at the root of the
  downloads folder tracks progress so re-runs only fetch new purchases.
- `FORMAT` is a single global setting requested for every release, not
  per-release auto-selection — if a release doesn't offer that exact
  encoding the item fails rather than falling back to another quality.
