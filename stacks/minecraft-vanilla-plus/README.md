# Minecraft Vanilla Plus

A Fabric Java edition server using the `itzg/minecraft-server` image, RCON
enabled for remote admin access. Runs alongside `minecraft-java` on the same
host — uses host ports 25566 (game) and 25576 (RCON) so it doesn't collide.

Fixed world seed (`SEED` in `.env`), hard difficulty, survival mode, 2G/4G
init/max heap, ops and whitelist `fourdirections`, `wifuy`, `fourtytwo`.

The world save goes in `${DATA_DIR}/world` — for a host inheriting an
existing world, place it there before first `docker compose up -d` so the
image loads it instead of generating a new one from `SEED`.

Start with:

```bash
cd ~/hosted-services/stacks/minecraft-vanilla-plus
sops -d .env.sops > .env
docker compose up -d
rm .env
```
