# Nextcloud All-in-One

This stack runs the `nextcloud/all-in-one` container.  It exposes ports 80/443 and 8080 for the management UI.

Set any env vars (e.g. `NEXTCLOUD_DATADIR`) in a local `.env` file if you wish.

Start it with:

```bash
cd ~/hosted-services/stacks/nextcloud
docker compose up -d
```