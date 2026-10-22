# arrgh-proton stack

This directory contains the compose file for the VPN and media download suite (`gluetun`, `qbittorrent`, `radarr`, `sonarr`, etc.).

The `gluetun` service provides a ProtonVPN tunnel that the other containers use via `network_mode: "service:gluetun"`.

`prowlarr` (port 9696) holds the private-tracker indexers for Sonarr and Radarr. `prowlarr-public` (port 9697, set with `PROWLARR__SERVER__PORT` because both share gluetun's network) holds public-tracker indexers only, for manual searches.

Update configuration values by editing environment variables in an `.env` file here if desired.  The compose file already embeds many hardcoded paths; adjust if you move storage.

To run:

```bash
cd ~/hosted-services/stacks/arrgh-proton
# create .env with your VPN credentials/keys
docker compose up -d
```
