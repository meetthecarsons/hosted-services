# Minecraft Vanilla Plus

A Fabric Java edition server using the `itzg/minecraft-server` image, RCON
enabled for remote admin access. Runs alongside `minecraft-java` on the same
host — uses host ports 25566 (game) and 25576 (RCON) so it doesn't collide.

Runs [Xisuma's Hermitcraft Server Pack](https://modrinth.com/modpack/hermitcraft)
(maintained upstream at [henkelmax/hermitcraft-server](https://github.com/henkelmax/hermitcraft-server)),
a Modrinth modpack built for dedicated servers. Fixed world seed (`SEED` in
`.env`), hard difficulty, survival mode, 2G/4G init/max heap, ops and
whitelist `fourdirections`, `wifuy`, `fourtytwo`.

The world save goes in `${DATA_DIR}/world` — for a host inheriting an
existing world, place it there before first `docker compose up -d` so the
image loads it instead of generating a new one from `SEED`.

## Mods

`MODRINTH_MODPACK` auto-installs, on every container start, whatever the
newest release of the pack is for the pinned `MODRINTH_LOADER`/`VERSION` —
no manual jar management. The pack bundles its own `fabric-api`, `lithium`,
and `ferrite-core` (the performance mods this stack used to install
individually via `MODRINTH_PROJECTS`); it does not include `hibernate-fabric`,
so the server no longer disables the image's built-in pause-when-empty —
`PAUSE_WHEN_EMPTY_SECONDS` is left at its default.

## Datapacks

Two independent sources, both landing in `world/datapacks/` additively —
neither is configured to remove the other's files:

- **Pack-bundled**: the modpack's `overrides/datapacks/` (~25 packs, e.g.
  wandering trades, name formatting station) extract to the container
  staging path `/data/datapacks` on every start. `DATAPACKS=/data/datapacks`
  in `compose.yaml` copies them into `world/datapacks/` from there —
  `REMOVE_OLD_DATAPACKS` is intentionally unset so this never prunes
  anything it didn't itself install.
- **Vanilla Tweaks**: `scripts/update-datapacks.sh` installs a fixed set of
  Vanilla Tweaks datapacks (edit the list in the script to change it) and
  restarts the container to apply. Vanilla Tweaks has no static per-pack
  URLs — packs are selected and zipped on demand via its API — so this
  can't be a plain list of download links. Run it on the host the stack is
  deployed to; it reads `DATA_DIR`/`VERSION` from the sibling `.env` and
  replaces whatever it installed last run (tracked in
  `world/datapacks/.vanillatweaks-manifest`) rather than accumulating stale
  versions. Restarting boots any connected players, so run it when the
  server's empty.

Start with:

```bash
cd ~/hosted-services/stacks/minecraft-vanilla-plus
sops -d .env.sops > .env
docker compose up -d
rm .env
```
