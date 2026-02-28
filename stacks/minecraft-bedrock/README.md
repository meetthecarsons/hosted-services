# Minecraft Bedrock Server

A simple bedrock edition server using the `itzg/minecraft-bedrock-server` image.

No special configuration; the container listens on UDP port 19132.  Edit the compose file or add a `.env` with `EULA=TRUE` if you need to.

Start with:

```bash
cd ~/hosted-services/stacks/minecraft-bedrock
docker compose up -d
```