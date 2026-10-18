# Minecraft Java Server

A Fabric Java edition server using the `itzg/minecraft-server` image, RCON
enabled for remote admin access. Datapacks work as on vanilla; WorldEdit and
Simple Voice Chat are installed server-side via `MODRINTH_PROJECTS`.

`MODRINTH_PROJECTS` is the complete mod list: the image deletes any other jar
in `mods/` on start, so add every mod there. Voice chat uses `24454/udp`
(published in the compose file); players need the Simple Voice Chat client mod,
and off-LAN players need that port forwarded.

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
