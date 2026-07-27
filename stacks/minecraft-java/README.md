# Minecraft Java Server

A vanilla Java edition server using the `itzg/minecraft-server` image, RCON
enabled for remote admin access.

Settings mirror the previous NixOS deployment: `easy` difficulty, `survival`
mode, 10 max players, ops `fourdirections` and `wifuy`, 2G/4G init/max heap.

The world save goes in `${DATA_DIR}/world` — for a host inheriting an
existing world, place it there before first `docker compose up -d` so the
image loads it instead of generating a new one.

Start with:

```bash
cd ~/hosted-services/stacks/minecraft-java
sops -d .env.sops > .env
docker compose up -d
rm .env
```
