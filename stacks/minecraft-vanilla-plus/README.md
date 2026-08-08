# Minecraft Vanilla Plus

A Fabric Java edition server using the `itzg/minecraft-server` image, RCON
enabled for remote admin access. Runs alongside `minecraft-java` on the same
host — uses host ports 25566 (game) and 25576 (RCON) so it doesn't collide.

Fixed world seed (`SEED` in `.env`), hard difficulty, survival mode, 2G/4G
init/max heap, ops and whitelist `fourdirections`, `wifuy`, `fourtytwo`.

The world save goes in `${DATA_DIR}/world` — for a host inheriting an
existing world, place it there before first `docker compose up -d` so the
image loads it instead of generating a new one from `SEED`.

## Mods

`MODRINTH_PROJECTS` auto-installs, on every container start, whatever the
newest build compatible with `TYPE`/`VERSION` is at the time — no manual
jar management:

- [`fabric-api`](https://modrinth.com/mod/fabric-api) — required by the mods below, no effect on its own.
- [`lithium`](https://modrinth.com/mod/lithium) — general server-side performance optimizations, no gameplay changes.
- [`ferrite-core`](https://modrinth.com/mod/ferrite-core) — reduces memory usage.
- [`hibernate-fabric`](https://modrinth.com/mod/hibernate-fabric) — puts the server to sleep (near-zero CPU) when no players are online, resumes on the next connection attempt. `PAUSE_WHEN_EMPTY_SECONDS=0` disables the image's own vanilla pause-when-empty so the two don't conflict, per the mod's own setup instructions.

All four are server-side only (verified via each project's Modrinth
`client_side`/`server_side` metadata) — players connect with a stock
client, no client-side install needed.

[`starlight`](https://modrinth.com/mod/starlight) (light-engine rewrite,
usually the biggest perf win of this family) has no build for this
server's Minecraft version yet — add it once one exists.

## Datapacks

`scripts/update-datapacks.sh` installs a fixed set of Vanilla Tweaks
datapacks (edit the list in the script to change it) and restarts the
container to apply. Vanilla Tweaks has no static per-pack URLs — packs are
selected and zipped on demand via its API — so this can't be a plain list
of download links. Run it on the host the stack is deployed to; it reads
`DATA_DIR`/`VERSION` from the sibling `.env` and replaces whatever it
installed last run (tracked in `world/datapacks/.vanillatweaks-manifest`)
rather than accumulating stale versions. Restarting boots any connected
players, so run it when the server's empty.

Start with:

```bash
cd ~/hosted-services/stacks/minecraft-vanilla-plus
sops -d .env.sops > .env
docker compose up -d
rm .env
```
